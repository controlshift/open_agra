class Org::MembersController < Org::OrgController
  before_filter :load_and_authorize_member, except: [:index, :email]

  def index
    @members = Member.paginate page: params[:page], order: 'created_at DESC', conditions: {organisation_id: current_organisation.id}
  end

  def show
  end

  def email
    @member = Member.find_by_email_and_organisation_id params[:email], current_organisation.id
    if @member
      redirect_to org_member_path(@member)
    else
      redirect_to org_members_path, alert: t('errors.messages.address_not_found')
    end
  end

private

  def load_and_authorize_member
    @member = Member.where(id: params[:id], organisation_id: current_organisation.id).first
    raise ActiveRecord::RecordNotFound if @member.organisation != current_organisation
    authorize_or_redirect! :manage, @member
  end

end
