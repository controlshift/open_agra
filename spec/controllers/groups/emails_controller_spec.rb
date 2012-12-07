require 'spec_helper'

describe Groups::EmailsController do
  include_context 'setup_default_organisation'

  context 'user not yet confirmed' do
    before(:each) do
      @user = create(:user, confirmed_at: nil, organisation: @organisation)
      @group = create(:group, organisation: @organisation)
      create(:group_member, user: @user, group: @group, invitation_email: @user.email)
      @email = { subject: 'test subject', body: 'test content' }
      sign_in @user
    end

    it 'should redirect to the confirmation page' do
      get :new,  group_id: @group
      response.should redirect_to(new_user_confirmation_path)
      session['after_confirmation_path'].should == new_group_email_path(@group)
    end
  end

  context 'user not login or unauthorised' do
    before :each do
      user = create(:user, confirmed_at: 1.day.ago,  organisation: @organisation)
      @group = Factory(:group, organisation: @organisation)
      create(:group_member, user: @user, group: @group, invitation_email: user.email)
    end

    it 'should not not allow non-logged user to GET #new' do
      get :new, group_id: @group
      response.should redirect_to new_user_session_path
    end

    it 'should not allow unauthorised user to GET #new' do
      another_user = create(:user)
      sign_in another_user
      get :new, group_id: @group
      response.should redirect_to(root_path)
    end

    it 'should not not allow non-logged user to POST #create' do
      post :create, group_id: @group
      response.should redirect_to new_user_session_path
    end

    it 'should not allow unauthorised user to  POST #create' do
      another_user = create(:user)
      sign_in another_user
      post :create, group_id: @group
      response.should redirect_to(root_path)
    end
  end

  context 'authorised user log in' do
    before :each do
      @user = create(:user, confirmed_at: 1.day.ago, organisation: @organisation)
      @group = create(:group, organisation: @organisation)
      create(:group_member, user: @user, group: @group, invitation_email: @user.email)
      @email = { subject: 'test subject', body: 'test content'}
      sign_in @user
    end

    describe '#new' do
      it 'should response to GET #new' do
        get :new, group_id: @group
        response.should be_success
      end

      it 'should clear the after_confirmation_path from the session' do
        session['after_confirmation_path'] = new_group_email_path(@group)
        get :new, group_id: @group
        session['after_confirmation_path'].should be_nil
      end
    end

    describe '#create' do
      it 'should send email to all supporters' do
        post :create, group_id: @group, group_blast_email: @email

        response.should redirect_to group_manage_path(@group)
        flash[:notice].should == 'Your email has been sent to your supporters.'
      end

      it 'should return to the new page for invalid emails' do
        post :create, group_id: @group, group_blast_email:  { body: 'test content' }

        response.should render_template :new
      end

    end

    describe '#test' do
      it 'should not send test email if email not valid' do
        blast_email = mock
        full_messages = mock
        errors = mock

        GroupBlastEmail.stub(:new) {blast_email}
        blast_email.stub(:valid?) {false}
        blast_email.should_receive(:group=){@group}

        blast_email.stub(:errors) {errors}
        blast_email.should_receive(:errors)
        full_messages.should_receive(:join) {'error messages'}
        errors.should_receive(:full_messages) {full_messages}

        post :test, group_id: @group, format: :json, group_blast_email: @email

        response.status.should == 406
        response.body.should have_content 'error messages'
      end

      it 'should not send test email if there is an exception' do
        exception = Exception.new('exception raised')
        subject.stub(:send_test_email_to_myself).and_raise(exception)

        post :test, group_id: @group, format: :json, group_blast_email: @email

        response.status.should == 406
        response.body.should have_content 'exception raised'
      end

      it 'should send test email to petition admin' do
        subject.should_receive(:send_test_email_to_myself)

        post :test, group_id: @group, format: :json, group_blast_email: @email

        response.should be_successful
        response.body.should have_content 'The test email has been sent.'
      end
    end
  end
end
