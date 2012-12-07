require 'spec_helper'

describe Petitions::EmailsController do
  include_context 'setup_default_organisation'
  
  context 'user not yet confirmed' do
    before(:each) do
      @user = Factory(:user, confirmed_at: nil, organisation: @organisation)
      @petition = Factory(:petition, user: @user, organisation: @organisation)
      @email = { subject: 'test subject', body: 'test content' }
      sign_in @user
    end
    
    it 'should redirect to the confirmation page' do
      get :new,  petition_id: @petition
      response.should redirect_to(new_user_confirmation_path)
      session['after_confirmation_path'].should == new_petition_email_path(@petition)
    end
  end

  context 'user not login or unauthorised' do
    before :each do
      user = Factory(:user, confirmed_at: 1.day.ago,  organisation: @organisation)
      @petition = Factory(:petition, user: user, organisation: @organisation)
    end

    it 'should not not allow non-logged user to GET #new' do
      get :new, petition_id: @petition
      response.should redirect_to new_user_session_path
    end

    it 'should not allow unauthorised user to GET #new' do
      another_user = Factory(:user)
      sign_in another_user
      get :new, petition_id: @petition
      response.should redirect_to(root_path)
    end

    it 'should not not allow non-logged user to POST #create' do
      post :create, petition_id: @petition
      response.should redirect_to new_user_session_path
    end

    it 'should not allow unauthorised user to  POST #create' do
      another_user = Factory(:user)
      sign_in another_user
      post :create, petition_id: @petition
      response.should redirect_to(root_path)
    end
  end

  context 'authorised user log in' do
    before :each do
      @user = Factory(:user, confirmed_at: 1.day.ago, organisation: @organisation)
      @petition = Factory(:petition, user: @user, organisation: @organisation)
      @email = { subject: 'test subject', body: 'test content'}
      sign_in @user
    end

    describe '#new' do
      it 'should response to GET #new' do
        get :new, petition_id: @petition
        response.should be_success
      end

      it 'should clear the after_confirmation_path from the session' do
        session['after_confirmation_path'] = new_petition_email_path(@petition)
        get :new, petition_id: @petition
        session['after_confirmation_path'].should be_nil
      end
    end

    describe '#create' do
      it 'should send email to all supporters' do
        post :create, petition_id: @petition, petition_blast_email: @email

        response.should redirect_to petition_manage_path(@petition)
        flash[:notice].should == 'Your email has been sent to your supporters.'
      end

      it 'should return error if subject is blank' do
        @email = { body: 'test content' }
        post :create, petition_id: @petition, petition_blast_email: @email

        response.should render_template :new
      end

      it 'should return error if content is blank' do
        @email = { subject: 'test subject' }
        post :create, petition_id: @petition, petition_blast_email: @email

        response.should render_template :new
      end

      it 'should not send blast if there have already been 3 this week' do
        3.times {
          post :create, petition_id: @petition, petition_blast_email: @email
          flash[:notice].should == 'Your email has been sent to your supporters.'
        }

          subject.should_not_receive(:send_email_to_supporters).with(kind_of(PetitionBlastEmail))
          post :create, petition_id: @petition, petition_blast_email: { subject: 'rejected subject', body: 'rejected content' }
          response.should render_template :new
      end
    end

    describe '#test' do
      it 'should not sent test email if email not valid' do
        blast_email = mock
        full_messages = mock
        errors = mock

        PetitionBlastEmail.stub(:new) {blast_email}
        blast_email.stub(:valid?) {false}
        blast_email.should_receive(:petition=){@petition}

        blast_email.stub(:errors) {errors}
        blast_email.should_receive(:errors)
        full_messages.should_receive(:join) {'error messages'}
        errors.should_receive(:full_messages) {full_messages}

        post :test, petition_id: @petition, format: :json, petition_blast_email: @email

        response.status.should == 406
        response.body.should have_content 'error messages'
      end

      it 'should not sent test email if there is an exception' do
        exception = Exception.new('exception raised')
        subject.stub(:send_test_email_to_myself).and_raise(exception)

        post :test, petition_id: @petition, format: :json, petition_blast_email: @email

        response.status.should == 406
        response.body.should have_content 'exception raised'
      end

      it 'should sent test email to petition admin' do
        subject.should_receive(:send_test_email_to_myself)
        
        post :test, petition_id: @petition, format: :json, petition_blast_email: @email
        
        response.should be_successful
        response.body.should have_content 'The test email has been sent.'
      end
    end
  end
end
