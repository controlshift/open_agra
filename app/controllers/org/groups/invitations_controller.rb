class Org::Groups::InvitationsController < Org::OrgController
  before_filter :load_and_authorize_group

  def create
    email = params[:group_member][:invitation_email]

    if invitation = GroupMember.find_by_invitation_email_and_group_id(email, @group.id)
      InvitationMailer.delay.send_to_group_admin(invitation)
      redirect_to org_group_users_path(@group), notice: "Invitation has been sent to #{email}"
    else
      invitation = GroupMember.new(invitation_email: email)
      invitation.group = @group
      invitation.user = current_organisation.users.find_by_email(email)

      if invitation.save
        InvitationMailer.delay.send_to_group_admin(invitation)
        redirect_to org_group_users_path(@group), notice: "Invitation has been sent to #{email}"
      else
        redirect_to org_group_users_path(@group), alert: "#{invitation.errors.full_messages.join(". ")}"
      end
    end
  end

  private
  def load_and_authorize_group
    @group = Group.find_by_slug! params[:group_id]
    authorize_or_redirect! :manage, @group
  end
end
