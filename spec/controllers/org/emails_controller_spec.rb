require 'spec_helper'

describe Org::EmailsController do
  include_context "setup_default_organisation"
  
  before(:each) do
    @user = Factory(:org_admin, organisation: @organisation)
    sign_in @user
  end

  describe "#index" do
    before(:each) { get :index }

    it { should assign_to :emails }
    it { should render_template :index }
  end

  describe "#show" do
    before(:each) do
      @email = Factory(:petition_blast_email)
      get :show, :id => @email

    end

    it { should assign_to :email }
    it { should render_template :show }
  end
  
  describe "#moderate" do
    context "with no emails" do
      before(:each) { get :moderation }
      it { should assign_to :emails }
      it { should render_template :moderation }
    end

    context "with some emails" do
      it "should only get pending emails" do
        petition = create(:petition, organisation: @organisation)
        group = create(:group, organisation: @organisation)
        pending_group_email = create(:group_blast_email, group: group, moderation_status: 'pending', organisation: @organisation)
        pending_petition_email = create(:petition_blast_email, petition: petition, moderation_status: 'pending', organisation: @organisation)
        approved_email = create(:petition_blast_email, petition: petition, moderation_status: 'approved', organisation: @organisation)
        inappropriate_email = create(:inappropriate_petition_blast_email, petition: petition, organisation: @organisation)

        get :moderation

        assigns(:emails).should == [ pending_petition_email, pending_group_email ]
        assigns(:emails).should_not include approved_email
        assigns(:emails).should_not include inappropriate_email
      end
    end
  end

  describe "#update" do
    it "should update the moderation fields" do
      BlastEmail.should_receive(:find).with('1').and_return(email = mock())
      email.should_receive(:moderation_status).and_return('pending')
      email.should_receive(:moderation_reason=)
      email.should_receive(:moderation_status=)

      BlastEmailsService.stub(:new).and_return(service = mock())
      service.should_receive(:save).with(email)

      post :update, :id => 1, :petition_blast_email => {:moderation_status => 'approved', :moderation_reason => 'foo'}
    end

    it "should not allow updates if the email is already moderated" do
      BlastEmail.should_receive(:find).with('1').and_return(email = mock())
      email.should_receive(:moderation_status).and_return('approved')
      email.should_not_receive(:moderation_reason=)
      email.should_not_receive(:moderation_status=)

      BlastEmailsService.stub(:new).and_return(service = mock())
      service.should_not_receive(:save).with(email)

      post :update, :id => 1, :petition_blast_email => {:moderation_status => 'approved', :moderation_reason => 'foo'}
      response.should be_redirect
    end
  end

end