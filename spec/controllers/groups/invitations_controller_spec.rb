require 'spec_helper'

describe Groups::InvitationsController do
  include_context 'setup_default_organisation'

  let(:invitation) { Factory(:group_member, user: nil) }
  let(:group) { invitation.group }
  let(:user) { Factory(:user, email: invitation.invitation_email) }

  describe '#show' do
    before :each do
      controller.should_not_receive(:authenticate_user!)
    end
    context 'user signed in' do
      before :each do
        sign_in(user)
      end
      context 'valid params' do
        context 'user is already linked to the group' do
          before :each do
            invitation.user = user
            invitation.save!
          end
          it 'redirects to the manage group' do
            get :show, group_id: group, id: invitation, group_member: {invitation_token: invitation.invitation_token}
            response.should redirect_to(group_manage_path(group))
          end
        end
        context 'user is not linked to the group' do
          it 'renders show page' do
            get :show, group_id: group, id: invitation, group_member: {invitation_token: invitation.invitation_token}
            response.should render_template('show')
          end
        end
      end
      context 'invalid params' do
        before :each do
          @controller.stub(:params_valid?) { false }
        end
        it 'redirects to root path' do
          get :show, group_id: group, id: invitation, group_member: {invitation_token: invitation.invitation_token}
          response.should redirect_to(root_path)
          flash.alert.should include 'Incorrect token or email'
        end
      end
    end
    context 'user not signed in' do
      it 'should redirect to registration and set the return path' do
        get :show, group_id: group, id: invitation
        session[:user_return_to].should == group_invitation_path(group, group_member: {invitation_token: invitation.invitation_token})
        response.should redirect_to(new_user_registration_path(email: invitation.invitation_email))
      end
    end
  end

  describe '#update' do
    before :each do
      controller.should_receive(:authenticate_user!)
      sign_in(user)
    end
    context 'valid params' do
      before :each do
        GroupMember.stub(:find_by_id).with("#{invitation.id}").and_return(invitation)
      end

      it 'links the user to the group and redirect to manage group page' do
        invitation.should_receive(:user=).with(user)
        invitation.should_receive(:save!)
        put :update, group_id: group, id: invitation, group_member: {invitation_token: invitation.invitation_token}
        response.should redirect_to(group_manage_path(group))
      end
    end

    context 'invalid params' do
      before :each do
        @controller.stub(:params_valid?) { false }
      end
      it 'redirects to root path' do
        put :update, group_id: group, id: invitation, group_member: {invitation_token: invitation.invitation_token}
        response.should redirect_to(root_path)
      end
    end
  end

  describe '#params_valid?' do
    it 'should return false if at least on of group, token or email it not the expected one' do
      controller.instance_variable_set(:@invitation, invitation)
      controller.instance_variable_set(:@group, group)
      controller.stub(:params).and_return({group_member: {invitation_token: "a_token"}})
      controller.stub(:current_user).and_return(user)
      controller.send(:params_valid?).should be_false
    end

    it 'should return true if group, token and email are the same as the expected one' do
      controller.instance_variable_set(:@invitation, invitation)
      controller.instance_variable_set(:@group, group)
      controller.stub(:params).and_return({group_member: {invitation_token: invitation.invitation_token}})
      controller.stub(:current_user).and_return(user)
      controller.send(:params_valid?).should be_true
    end
  end
end
