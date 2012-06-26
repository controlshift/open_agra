class Petitions::ViewController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show, :show_alias, :thanks]

  before_filter :load_petition, except: [:show_alias]
  before_filter :load_petition_by_alias, only: [:show_alias]
  has_mobile_fu
  include MobileFuOverrides

  def show
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
    @petition = Petition.where(slug: params[:id]).includes(:user).first!
  end
  
  def load_petition_by_alias
    @petition = Petition.where(alias: params[:id]).includes(:user).first!
  end

  def show_as_public
    if @petition.cancelled? || !@petition.launched?
      redirect_to root_path, alert: "We're sorry, this petition is not available."
    elsif @petition.prohibited?
      render 'show_inappropriate'
    else
      @signature = Signature.new(current_user ? current_user.accessible_attributes_hash_values : {})
      @email = Email.new
      render 'show', layout: 'application_sidebar'
    end
  end

  def show_as_admin_or_owner
    if @petition.launched?
      @signature = Signature.new(current_user ? current_user.accessible_attributes_hash_values : {})
      @email = Email.new
      render 'show', layout: 'application_sidebar'
    else
      redirect_to launch_petition_path(@petition), alert: 'Petition must be launched before it can be managed.'
    end
  end
end
