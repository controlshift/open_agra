require 'spec_helper'

describe Petitions::ManageController do
  include_context "setup_default_organisation"
  include Shoulda::Matchers::ActionMailer

  let(:user) { Factory(:user) }

  describe "an inappropriate petition" do
    before(:each) do
      @petition = Factory(:inappropriate_petition, user: user, organisation: @organisation)
      sign_in user
    end

    [:offline, :deliver].each do |action|
      before(:each) { get action, petition_id: @petition.slug }

      it "should redirect to manage for #{action}" do
        response.should redirect_to petition_manage_path(@petition)
      end
    end

    it "should render show_inappropriate page" do
      get :show, petition_id: @petition.slug
      response.should render_template('show_inappropriate')
    end
  end

  context "signed in as petition owner" do
    before(:each) do
      @petition = Factory(:petition, user: user, organisation: @organisation)
      sign_in user
    end

    describe "#activate" do
      before(:each) do
        @petition.update_attribute(:cancelled, true)
      end

      it "should activate petition" do
        put :activate, petition_id: @petition
        response.should redirect_to petition_manage_path(@petition)

        Petition.find_by_id(@petition.id).cancelled?.should be_false
        flash[:notice].should == "Your petition has been reactivated!"
      end
    end

    describe "#show" do
      it "should render show page" do
        get :show, petition_id: @petition.slug
        response.should render_template(:show)
      end
    end

    describe "#cancel" do
      it "should cancel the petition" do
        put :cancel, petition_id: @petition
        response.should redirect_to petition_manage_path(@petition)

        Petition.find_by_id(@petition.id).cancelled?.should be_true
      end
    end

    describe "#update" do
      describe "valid petition" do
        it "should redirect to manage page" do
          petition_attributes = { 'id' => '2' }
          controller.should_receive(:update_petition).with(@petition, petition_attributes, nil).and_return(true)
          put :update, petition_id: @petition, petition: petition_attributes
          response.should redirect_to petition_path(@petition)
        end
      end

      describe "invalid petition" do
        it "should render edit page" do
          petition_attributes = { 'id' => '2' }
          controller.should_receive(:update_petition).with(@petition, petition_attributes, nil).and_return(false)
          put :update, petition_id: @petition, petition: petition_attributes
          response.should render_template "edit"
        end
      end

      it "should handle a partial update" do
        PetitionsService.should_receive(:new).and_return(service = mock())
        service.should_receive(:update_attributes).with(@petition, {:campaigner_contactable => false}).and_return(@petition)

        put :update, {:petition =>{"campaigner_contactable"=>false}, :petition_id =>@petition.slug, format: :js}
        response.should be_successful
      end

      describe 'location provided' do
        it 'passes location' do 
          petition_attributes = { 'id' => '2' }
          location_attributes = { 'query' => 'Australia' }
          controller.should_receive(:update_petition).with(@petition, petition_attributes, location_attributes).and_return(true)
          put :update, petition_id: @petition, petition: petition_attributes, location: location_attributes
          response.should redirect_to petition_path(@petition)
        end
      end
      
      describe "#check_alias" do
        it "should return ok status if alias is valid" do
          post :check_alias, petition_id: @petition, alias: "test"
          response.should be_successful
        end
        
        it "should return ok status if alias is valid but some other attribute is invalid" do
          @petition.title = ""
          post :check_alias, petition_id: @petition, alias: "test"
          response.should be_successful
        end
        
        it "should return not_acceptable status if alias is invalid" do
          post :check_alias, petition_id: @petition, alias: "t"
          response.should_not be_successful
        end
      end
      
      describe "#update_alias" do
        describe "success" do
          before(:each) do
            post :update_alias, petition_id: @petition, alias: "test"
          end

          it "should return ok status if petition alias could be saved" do
            response.should be_successful
          end

          it "should return appropriate JSON" do
            json = JSON.parse(response.body)
            json.should == {'url' => petition_alias_url('test')}
          end
        end
        
        it "should return not_acceptable status if failed to save petition alias" do
          post :update_alias, petition_id: @petition, alias: "t"
          response.should_not be_successful
          json = JSON.parse(response.body)
          json.has_key?('message').should be_true
        end
      end
    end
    
    it "should return petition_form in pdf format" do
      get "download_form", petition_id: @petition
      response.headers["Content-Type"].should match 'application/pdf'
      response.headers['Content-Disposition'].should match "#{@petition.slug}_form"
    end

    describe "lots of signatures" do
      before(:each) do
        Petition.any_instance.stub(:cached_signatures_size).and_return(1000)
      end

      it "should generate petition letter in background and notice user" do
        filename = "#{@petition.slug}_form.pdf"

        job = mock
        Jobs::GeneratePetitionLetterJob.stub(:new).with(@petition, filename, user) { job }
        Delayed::Job.should_receive(:enqueue).with(job)

        get :download_letter, petition_id: @petition

        response.should redirect_to deliver_petition_manage_path(@petition)
        flash[:notice].should == "#{user.email} will receive an email with download instructions as soon as the PDF has been generated."
      end
    end

    describe "few signatures" do
      before(:each) do
        Petition.any_instance.stub(:cached_signatures_size).and_return(10)
      end

      it "should generate petition letter and send it to the user" do
        get :download_letter, petition_id: @petition
        response.should be_success
        flash[:notice].should == nil
      end
    end
  end

  describe "#contact_admin" do
    before :each do
      @petition = Factory(:inappropriate_petition, user: user, organisation: @organisation)
      sign_in user
    end

    it "should send email to organisation administrator" do
      email_attributes = {"subject" => "Test", "content" => "Test Content"}

      email = mock
      Email.should_receive(:new).with(email_attributes) { email }
      email.should_receive(:from_name=).with(user.full_name)
      email.should_receive(:from_address=).with(user.email)
      email.should_receive(:to_address=).with(@organisation.admin_email)
      email.should_receive(:save) { true }

      delayed_job = mock
      UserMailer.stub(:delay) { delayed_job }
      delayed_job.should_receive(:contact_admin).with(@petition, email)

      post :contact_admin, petition_id: @petition, email: email_attributes

      response.should redirect_to petition_manage_path(@petition)
      flash[:notice].should have_content "Thank you for contacting us, we will review your petition soon."
    end

    it "should not send email if email cannot be saved" do
      UserMailer.should_not_receive(:delay)
      post :contact_admin, petition_id: @petition, email: {}
      response.should render_template "show_inappropriate"
    end
  end
end
