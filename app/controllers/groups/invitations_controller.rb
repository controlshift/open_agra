class Groups::InvitationsController < ApplicationController
  before_filter :load_group_and_invitation
  skip_before_filter :authenticate_user!, only: [:show]

  def update
    if params_valid?
      @invitation.user = current_user
      @invitation.save!
      redirect_to group_manage_path(@group)
    else
      invalid_params
    end
  end

  def show
    if user_signed_in?
      if params_valid?
        if @invitation.user.present?
          redirect_to group_manage_path(@group)
        else
          render :show
        end
      else
        invalid_params
      end
    else
      session[:user_return_to] = group_invitation_path(@invitation.group, @invitation, group_member: {invitation_token: @invitation.invitation_token})
      redirect_to new_user_registration_path(email: @invitation.invitation_email)
    end
  end

  private

  def params_valid?
    @invitation.group == @group &&
        params[:group_member].present? && params[:group_member][:invitation_token].present? &&
        @invitation.invitation_token == params[:group_member][:invitation_token] &&
        @invitation.invitation_email.strip.downcase == current_user.email.strip.downcase
  end

  def invalid_params
    redirect_to root_path, alert: 'Incorrect token or email address for group invitation.'
  end

  def load_group_and_invitation
    @invitation = GroupMember.find_by_id(params[:id])
    @group = Group.find_by_slug!(params[:group_id])
  end
end