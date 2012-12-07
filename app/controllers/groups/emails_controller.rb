class Groups::EmailsController < ApplicationController

  before_filter :load_and_authorize_group, :verify_user_can_send_email

  def new
    @email = GroupBlastEmail.new
  end

  def create
    @email = GroupBlastEmail.new(params[:group_blast_email].merge(from_name: current_user.full_name,
                                                                        from_address: current_user.email))

    @email.group = @group
    @email.organisation = @group.organisation

    if BlastEmailsService.new.save(@email)
      if @email.in_delivery?
        notice = 'Your email has been sent to your supporters.'
      else
        notice = 'Your email has been sent to an administrator for approval.'
      end

      redirect_to group_manage_path(@group), notice: notice
    else
      render :new
    end
  end

  def test
    @email = GroupBlastEmail.new(params[:group_blast_email].merge(from_name: current_user.full_name,
                                                                  from_address: current_user.email))
    @email.group = @group

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

  def load_and_authorize_group
    @group = Group.find_by_slug!(params[:group_id])
    raise ActiveRecord::RecordNotFound if @group.organisation != current_organisation
    authorize! :manage, @group
  end

  def verify_user_can_send_email
    if current_user.confirmed?
      session['after_confirmation_path'] = nil
      true
    else
      session['after_confirmation_path'] = new_group_email_path(@group)
      redirect_to new_user_confirmation_path
    end
  end

  def send_test_email_to_myself
    @email.send_test_email
  end

end
