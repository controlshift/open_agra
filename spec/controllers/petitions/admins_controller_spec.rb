require 'spec_helper'

describe Petitions::AdminsController do
  include_context 'setup_default_organisation'

  context 'petition exist' do
    let(:campaigner) { Factory(:user, organisation: @organisation)}
    let(:petition) { Factory(:petition, user: campaigner, organisation: @organisation) }
    let(:email) { 'email@emailfake.com' }
    let(:token) { 'LSJzu7kKMGfQqxzyZsbJ' }

    context 'not authorised user' do

      context 'user not login' do
        specify do
          get :new, petition_id: petition
          should_redirect_to_login
        end

        specify do
          post :create, campaign_admin: {invitation_email: email}, petition_id: petition
          should_redirect_to_login
        end

        specify do
          campaign_admin = Factory(:campaign_admin, invitation_email: campaigner.email, petition: petition, user: campaigner)
          delete :destroy, id: campaign_admin, petition_id: petition
          should_redirect_to_login
        end

        def should_redirect_to_login
          response.should redirect_to new_user_session_path
        end
      end

      context 'user is not authorised to the petition' do
        before :each do
          another_user = Factory(:user, organisation: @organisation)
          sign_in(another_user)
        end

        specify do
          get :new, petition_id: petition
          should_redirect_to_home
        end

        specify do
          post :create, campaign_admin: {invitation_email: email}, petition_id: petition
          should_redirect_to_home
        end

        def should_redirect_to_home
          response.should redirect_to root_path
        end
      end
    end

    context 'authorised user' do
      before :each do
        sign_in(campaigner)
      end

      describe '#new' do
        it 'should create a new campaign object' do
          Factory(:campaign_admin, invitation_email: campaigner.email, petition: petition, user: campaigner)
          
          get :new, petition_id: petition

          assigns(:campaign_admin).should_not be_nil
          response.should render_template :new
        end
      end

      describe '#create' do
        context 'potential admin has not been invited yet' do

          it 'should create and send invitation' do
            CampaignAdmin.stub(:find_by_invitation_email_and_petition_id).with(email, petition.id).and_return(nil)
            invitation = should_create_invitation
            should_send_invitation(invitation)
          end

          it 'should not send invitation if invitation is not created successfully' do
            InvitationMailer.should_not_receive(:delay)

            post :create, campaign_admin: {invitation_email: 'invalid_email'}, petition_id: petition

            assigns(:campaign_admin).should_not be_nil
            flash.alert.should_not be_nil
            response.should render_template :new
          end

        end

        context 'potential admin has already been invited' do
          before :each do
            @invitation = mock
            CampaignAdmin.stub(:find_by_invitation_email_and_petition_id).with(email, petition.id).and_return(@invitation)
          end

          it 'resends same invitation' do
            should_send_invitation(@invitation)
          end
        end

        context 'invite petition creator' do
          it 'should not send invitation' do
            InvitationMailer.should_not_receive(:delay)

            post :create, campaign_admin: {invitation_email: campaigner.email}, petition_id: petition

            flash.alert.should == 'You cannot invite campaign creator'
            response.should render_template :new
          end
        end
      end

      describe '#destroy' do
        before :each do
          @campaign_admin = Factory(:campaign_admin, petition: petition, user: campaigner, invitation_email: campaigner.email)
        end

        it 'should not delete if petition and campaign admin not match' do
          CampaignAdmin.count.should == 1
          another_petition = Factory(:petition, user: campaigner, organisation: @organisation)

          -> {delete :destroy, petition_id: another_petition, id: @campaign_admin}.should raise_exception(ActiveRecord::RecordNotFound)
          CampaignAdmin.count.should == 1
        end

        it 'should delete the petition' do
          CampaignAdmin.count.should == 1

          delete :destroy, petition_id: petition, id: @campaign_admin

          CampaignAdmin.count.should == 0
          flash.notice.should == "Admin '#{@campaign_admin.invitation_email}' has been removed from the campaign admin list."
        end
      end

      def mock_send_invitation(invitation)
        delayed_job = mock
        delayed_job.should_receive(:send_to_campaign_admin).with(invitation)
        InvitationMailer.stub(:delay) { delayed_job }
      end

      def should_send_invitation(invitation)
        mock_send_invitation(invitation)

        post :create, campaign_admin: {invitation_email: email}, petition_id: petition

        response.should redirect_to new_petition_admin_path(petition)
        flash.notice.should  == "Invitation email has been sent to #{email}"
      end

      def should_create_invitation
        invitation = mock
        CampaignAdmin.should_receive(:new).with(invitation_email: email).and_return(invitation)
        invitation.should_receive(:petition=).with(petition)
        invitation.should_receive(:user=)
        invitation.should_receive(:save).and_return(true)
        invitation
      end
    end

    describe '#show' do
      let(:campaign_admin) {Factory(:campaign_admin, invitation_email: email, petition: petition, user: nil)}
      let(:potential_admin) {Factory(:user, organisation: @organisation, email: email)}

      context 'user is not sign in' do
        it 'should redirect to sign up page' do
          get :show, campaign_admin: {invitation_token: campaign_admin.invitation_token}, id: campaign_admin, petition_id: petition

          session[:user_return_to].should include petition_admin_path
          response.should redirect_to new_user_registration_path(email: email)
        end
      end

      context 'sign in as a potential admin' do
        before :each do
          sign_in(potential_admin)
        end

        it 'should set campaign admin' do
          get :show, campaign_admin: {invitation_token: campaign_admin.invitation_token}, id: campaign_admin, petition_id: petition

          campaign_admin.reload
          campaign_admin.user.should == potential_admin
          response.should redirect_to petition_manage_path(petition)
        end
      end

      context 'sign in user with invalid params' do
        it 'should reject if petition and invitation not match' do
          another_petition = Factory(:petition, user: campaigner, organisation: @organisation)
          sign_in(potential_admin)
          get :show, campaign_admin: {invitation_token: campaign_admin.invitation_token}, id: campaign_admin, petition_id: another_petition

          should_deny_access
        end

        it 'should reject if no invitation provided' do
          sign_in(potential_admin)
          get :show, id: campaign_admin, petition_id: petition

          should_deny_access
        end

        it 'should reject if no invitation token provided' do
          sign_in(potential_admin)
          get :show, campaign_admin: {invitation_email: email}, id: campaign_admin, petition_id: petition

          should_deny_access
        end

        it 'should reject if invitation token not match' do
          sign_in(potential_admin)
          get :show, campaign_admin: {invitation_token: 'other_token'}, id: campaign_admin, petition_id: petition

          should_deny_access
        end

        it 'should reject if user email not match' do
          sign_in(Factory(:user, organisation: @organisation))
          get :show, campaign_admin: {invitation_token: campaign_admin.invitation_token}, id: campaign_admin, petition_id: petition

          should_deny_access
        end

        def should_deny_access
          response.should redirect_to root_path
          flash.alert.should == 'Incorrect token or email address for petition admin invitation.'
        end
      end
    end
  end
end