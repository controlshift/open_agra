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
    @signature = Signature.new(params[:signature])
    @signature.petition = @petition

    respond_to do | format|
      if SignaturesService.new.save(@signature)
        track! :opt_to_join_org if @signature.join_organisation?
        track! :sign_petition
        format.html { redirect_to thanks_petition_path(@petition) }
        format.js   { render :create, layout: false }
      elsif @signature.errors[:email] && @signature.errors[:email].include?('has already signed')
        format.html { redirect_to thanks_petition_path(@petition) }
        format.js   { render :create, layout: false }
      else
        @email = Email.new
        format.html { render 'petitions/view/show', layout: 'application_sidebar' }
        format.js   { render :error, layout: false }
      end
    end
  end

  def index
    respond_to do |format|
      format.csv { render csv: @petition, filename: @petition.slug, fields: [:first_name, :last_name, :phone_number, :postcode] }
    end
  end

  def manual_input
    @signature = Signature.new
    @signature.petition = @petition
    @signatures_with_errors = []
    @error_rows_json = '[]'

    render :manual_input
  end

  def save_manual_input
    @signature = Signature.new
    @signature.petition = @petition
    @signatures_with_errors = []

    signatures = params[:signatures]
    saved_signatures = 0

    signatures.each do |hash|
      if hash.any? { |k, v| !v.blank? }
        signature = Signature.new(hash)
        signature.petition = @petition

        if signature.valid?
          if SignaturesService.new.save(signature)
            saved_signatures += 1
          else
            @signatures_with_errors << signature
          end
        else
          @signatures_with_errors << signature
        end
      end
    end

    @error_rows_json = "[#{@signatures_with_errors.map { |sign| sign.to_json(methods: :errors) }.join(', ')}]"

    
    if !@signatures_with_errors.empty?
      flash.now.notice = "#{pluralize(saved_signatures, 'signature')} saved." unless saved_signatures == 0
      flash.now.alert = "#{pluralize(@signatures_with_errors.count, 'signature')} cannot be saved." unless @signatures_with_errors.empty?
      render :manual_input
    else
      flash.notice = "#{pluralize(saved_signatures, 'signature')} saved." unless saved_signatures == 0
      redirect_to petition_manage_path(@petition)
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
    @petition = Petition.find_by_slug!(params[:petition_id])
  end

  def load_signature
    @signature = Signature.find_by_token! params[:id]
  end

  def authorize_petition
    authorize! :manage, @petition
  end
  
  include PetitionFilters
end
