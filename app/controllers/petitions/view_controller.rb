class Petitions::ViewController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show, :show_alias, :thanks, :show_comments]

  before_filter :load_petition, except: [:show_alias]
  before_filter :load_petition_by_alias, only: [:show_alias]
  has_mobile_fu
  include MobileFuOverrides

  def show
    if cookies[:signature_id]
      if cookies[:signature_id].present?
        @previous_signature = Signature.find(cookies[:signature_id])
        @comment = Comment.new
      elsif current_user
        @previous_signature = Signature.new(email: current_user.email)
        @previous_signature.petition = @petition
      end
    end
    # special case for 38 Degrees.
    if @petition.redirect_to.present?
      redirect_to @petition.redirect_to
      return
    end
    @petition.facebook_share.choose
    if can? :manage, @petition
      show_as_admin_or_owner
    else
      show_as_public
    end
  end

  def show_alias
    redirect_to petition_path(@petition)
  end

  def thanks
  end

  private

  def load_petition
    @petition = Petition.load_petition(params[:id])
    raise  ActiveRecord::RecordNotFound  if @petition.organisation != current_organisation
  end

  def load_petition_by_alias
    @petition = Petition.where(alias: params[:id]).includes(:user).first!
    raise ActiveRecord::RecordNotFound  if @petition.organisation != current_organisation
  end

  def show_as_public
    if @petition.cancelled? || !@petition.launched?
      redirect_to_alert
    elsif @petition.prohibited?
      show_inappropriate
    elsif has_facebook_user_agent?
      optimize_share
    else
      render_petition
    end
  end

  def optimize_share
    if @petition && @petition.facebook_share.variant.present?
      redirect_to petition_facebook_share_variant_path([@petition, @petition.facebook_share.variant])
    else
      render_petition
    end
  end

  def redirect_to_alert
    not_available_message = t('controllers.petitions.view.unavailable')
    respond_to do |format|
      format.any(:html, :mobile) { redirect_to root_path, alert: not_available_message }
      format.json { render json: {error: true, msg: not_available_message}, callback: params[:callback] }
    end
  end

  def show_inappropriate
    respond_to do |format|
      format.any(:html, :mobile) { render 'show_inappropriate' }
      format.json { render json: {error: true, msg: t('controllers.petitions.view.inappropriate')}, callback: params[:callback] }
    end
  end

  def render_petition
    respond_to do |format|
      format.any(:html, :mobile) {
        @signature = Signature.new(default_organisation_slug: current_organisation.slug, source: params[:source], akid: params[:akid])
        if current_user
          signature_attributes = current_user.signature_attributes(@signature)
          @signature.assign_attributes( signature_attributes )
        end
        render 'show', layout: 'application_sidebar'
      }
      format.json { render json: petition_info, callback: params[:callback]}
    end
  end

  def petition_info
    basic_info = @petition.serializable_hash(only: [:administered_at, :alias, :bsd_constituent_group_id, :delivery_details,
                                          :location_id, :slug, :source, :title, :id, :created_at, :updated_at,
                                          :who, :why, :what], include: {categories: {only: [:name, :slug]}})
    advanced_info = {
        goal: @petition.goal,
        effort: @petition.effort ? @petition.effort.slug: nil,
        group: @petition.group ? @petition.group.slug: nil,
        image_url: @petition.image.url,
        creator_name: @petition.user.full_name,
        last_signed_at: @petition.signatures.any? ? @petition.signatures.last.created_at : nil,
        signature_count: @petition.cached_signatures_size
    }

    basic_info.merge(advanced_info)
  end

  def show_as_admin_or_owner
    if @petition.launched?
      render_petition
    else
      redirect_to launch_petition_path(@petition), alert: t('controllers.petitions.view.unlaunched')
    end
  end
end
