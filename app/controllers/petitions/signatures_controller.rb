class Petitions::SignaturesController < ApplicationController
  include ActionView::Helpers::TextHelper

  PUBLIC_ACTIONS = [:create, :confirm_destroy, :destroy, :unsubscribing, :unsubscribe]
  
  before_filter :load_petition
  before_filter :load_signature, only: [:confirm_destroy, :destroy, :unsubscribing, :unsubscribe]
  before_filter :authorize_petition, :verify_petition_is_launched, :verify_petition_can_be_managed, except: PUBLIC_ACTIONS
  skip_before_filter :authenticate_user!, only: PUBLIC_ACTIONS

  has_mobile_fu
  has_no_mobile_fu_for :index, :confirm_destroy, :destroy, :unsubscribing, :unsubscribe, :manual_input, :save_manual_input
  include MobileFuOverrides

  def create
    @signature = Signature.new(default_organisation_slug: current_organisation.slug)
    @signature.assign_attributes(params[:signature])
    @signature.petition = @petition

    respond_to do | format|
      if SignaturesService.new.save(@signature)
        track! :opt_to_join_org if @signature.join_organisation?
        track! :sign_petition
        format.any(:html, :mobile) { redirect_to thanks_petition_path(@petition) }
        format.js   { render :create, layout: false }
      elsif @signature.errors[:email] && @signature.errors[:email].include?('has already signed') && @signature.errors.size == 1
        format.any(:html, :mobile) { redirect_to thanks_petition_path(@petition) }
        format.js   { render :create, layout: false }
      else
        @email = Email.new
        format.any(:html, :mobile) { render 'petitions/view/show', layout: 'application_sidebar' }
        format.js   { render :error, layout: false }
      end
    end
  end

  def index
    streaming_csv( Queries::Exports::PetitionSignaturesExport.new(petition: @petition, organisation: current_organisation) )
  end

  def manual_input
    @signature = Signature.new(default_organisation_slug: current_organisation.slug)
    @signature.petition = @petition
    @error_rows = []

    render :manual_input
  end

  def save_manual_input
    @signature = Signature.new(default_organisation_slug: current_organisation.slug)
    @signature.petition = @petition
    @error_rows = []
    @saved_signatures = 0

    params[:signatures].each do |hash|
      if hash.any? { |k, v| !v.blank? && k != 'join_organisation' }
        signature = Signature.new(default_organisation_slug: current_organisation.slug)
        signature.assign_attributes hash
        signature.petition = @petition

        if signature.valid? && SignaturesService.new.save(signature)
          @saved_signatures += 1
        else
          @error_rows << signature.to_hash
        end
      end
    end
    
    @success_text = @saved_signatures > 0 ? "#{pluralize(@saved_signatures, 'signature')} saved." : ""
    @error_text = @error_rows.empty? ? "" : "#{pluralize(@error_rows.count, 'signature')} cannot be saved."

    respond_to do |format|
      format.html do
        flash.notice = @success_text if @success_text.present?
        
        if @error_rows.empty?
          redirect_to petition_manage_path(@petition)
        else
          flash.now.alert = @error_text if @error_text.present?
          render :manual_input
        end
      end
      format.js do
        render :manual_input, layout: false
      end
    end
  end

  def confirm_destroy
  end

  def destroy
    if @signature.petition == @petition && SignaturesService.new.delete(@signature)
      flash[:notice] = 'Your signature has been removed from the petition.'
      redirect_to petition_path(@petition)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def unsubscribing
    @unsubscribe = Unsubscribe.new(:email => @signature.email, :petition => @petition, :signature => @signature)
  end

  def unsubscribe
    @unsubscribe = Unsubscribe.new(:signature => @signature, :petition => @petition, :email => params[:unsubscribe][:email].strip)

    if @unsubscribe.unsubscribe
      flash[:notice] = 'You have successfully unsubscribed from the petition.'
      redirect_to petition_path(@petition)
    else
      render :unsubscribing
    end
  end

  private
  
  def load_petition
    # TEMPORARY FIX FOR BUG!!! Revert sometime in 2013.
    @petition = Petition.find_by_slug(params[:petition_id])
    if @petition.nil?
      @petition = PetitionBlastEmail.find_by_id!(params[:petition_id]).petition
    end

    raise ActiveRecord::RecordNotFound if @petition.nil?
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
  end

  def load_signature
    @signature = Signature.find_by_token! params[:id]
  end

  def authorize_petition
    authorize! :manage, @petition
  end
  
  include PetitionFilters
end
