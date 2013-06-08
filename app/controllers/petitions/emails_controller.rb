class Petitions::EmailsController < ApplicationController
  layout 'application_sidebar'
  include PetitionFilters

  before_filter :load_and_authorize_petition, :verify_petition_is_launched, :verify_petition_can_be_managed,
                :verify_user_can_send_email

  before_filter :setup_email, only: [:create, :test]


  def new
    @email = PetitionBlastEmail.new({body: (render_to_string partial: 'petitions/emails/blast_email_body_template',
                                                            locals: {petition: @petition})}.merge(email_settings_hash))
  end

  def create
    if BlastEmailsService.new.save(@email)
      if @email.in_delivery?
        notice = t('controllers.email.success')
      else
        notice = t('controllers.email.approval_required')
      end

      redirect_to petition_manage_path(@petition), notice: notice
    else
      render :new
    end
  end

  def test
    respond_to do |format|
      if @email.valid?
        begin
          send_test_email_to_myself
          format.json { render json: {message: t('controllers.email.test_success')}, status: :ok }
        rescue Exception => e
          format.json { render json: {message: e.message}, status: :not_acceptable }
        end
      else
        format.json { render json: {message: "#{@email.errors.full_messages.join('. ')}"}, status: :not_acceptable }
      end
    end
  end

  private

  def setup_email
    @email = PetitionBlastEmail.new(params[:petition_blast_email].merge(email_settings_hash))
    @email.petition = @petition
    @email.organisation = @petition.organisation
  end

  def email_settings_hash
    if current_organisation.expose_broadcast_emails? || action_name == 'test'
      {from_name: "#{current_user.full_name} via #{current_organisation.name}".slice(0..199), from_address: current_user.email}
    else
      {from_name: "#{current_user.full_name} via #{current_organisation.name}".slice(0..199), from_address: current_organisation.contact_email}
    end
  end

  def load_and_authorize_petition
    @petition = Petition.find_by_slug!(params[:petition_id])
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
    authorize! :manage, @petition
  end

  def send_test_email_to_myself
    @email.send_test_email
  end

  def verify_user_can_send_email
    if current_user.confirmed?
      session['after_confirmation_path'] = nil
      true
    else
      session['after_confirmation_path'] = new_petition_email_path(@petition)
      redirect_to new_user_confirmation_path
    end
  end
end
