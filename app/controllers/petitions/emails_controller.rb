class Petitions::EmailsController < ApplicationController
  before_filter :load_and_authorize_petition, :verify_petition_is_launched, :verify_petition_can_be_managed,
                :verify_user_can_send_email

  layout 'application_sidebar'

  def new
    @email = PetitionBlastEmail.new(body: (render_to_string partial: 'petitions/emails/blast_email_body_template',
                                                            locals: {petition: @petition}))
  end

  def create
    @email = PetitionBlastEmail.new(params[:petition_blast_email].merge(from_name: current_user.full_name,
                                                                        from_address: current_user.email))
    @email.petition = @petition
    @email.organisation = @petition.organisation

    if BlastEmailsService.new.save(@email)
      if @email.in_delivery?
        notice = 'Your email has been sent to your supporters.'
      else
        notice = 'Your email has been sent to an administrator for approval.'
      end

      redirect_to petition_manage_path(@petition), notice: notice
    else
      render :new
    end
  end

  def test
    @email = PetitionBlastEmail.new(params[:petition_blast_email].merge(from_name: current_user.full_name,
                                                                        from_address: current_user.email))
    @email.petition = @petition

    respond_to do |format|
      if @email.valid?
        begin
          send_test_email_to_myself
          format.json { render json: {message: 'The test email has been sent.'}, status: :ok }
        rescue Exception => e
          format.json { render json: {message: e.message}, status: :not_acceptable }
        end
      else
        format.json { render json: {message: "#{@email.errors.full_messages.join('. ')}"}, status: :not_acceptable }
      end
    end
  end

  private

  def load_and_authorize_petition
    @petition = Petition.find_by_slug!(params[:petition_id])
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
    authorize! :manage, @petition
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

  include PetitionFilters

  def send_test_email_to_myself
    @email.send_test_email
  end

end
