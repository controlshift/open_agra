require 'spec_helper'

describe Petitions::ContactsController do
  include_context "setup_default_organisation"
  include Shoulda::Matchers::ActionMailer

  describe "#create" do
    before(:each) do
      @petition_owner = FactoryGirl.create(:user, organisation: @organisation)
      @petition_admin = FactoryGirl.create(:user, organisation: @organisation)
      @petition = FactoryGirl.create(:petition, user: @petition_owner, organisation: @organisation)
      FactoryGirl.create(:campaign_admin, petition: @petition, user: @petition_admin, invitation_email: @petition_admin.email)
      @email = Factory.attributes_for(:email)
      Sidekiq::Worker.clear_all
    end

    context "valid contact email" do
      it "should send email to the current petition's campaigner" do
        post :create, petition_id: @petition.slug, email: @email

        should_have_sent_contact_email
        response.should redirect_to petition_path(@petition)
        flash[:notice].should have_content "has been sent"
      end

      it "should not send email from supporter if campaigner is not contactable" do
        @petition.update_attribute(:campaigner_contactable, false)

        post :create, petition_id: @petition.slug, email: @email

        response.should redirect_to petition_path(@petition)
        flash[:alert].should have_content "The leader of this campaign may not be contacted."
      end

      it "should send email from org admin even if campaigner is not contactable" do
        @petition.update_attribute(:campaigner_contactable, false)

        org_admin = FactoryGirl.create(:org_admin, organisation: @organisation)
        sign_in org_admin

        post :create, petition_id: @petition.slug, email: @email

        should_have_sent_contact_email
        response.should redirect_to petition_path(@petition)
        flash[:notice].should have_content "has been sent"
      end
    end

    context "invalid contact email" do
      it "redirect to the petition page with an alert message" do
        @email[:from_address] = "asdlajkd"
        @mailer = mock
        @mailer.should_not_receive(:deliver)
        UserMailer.should_not_receive(:contact_campaigner).and_return(@mailer)
        post :create, petition_id: @petition, email: @email

        response.should redirect_to petition_path(@petition)
        flash[:alert].should have_content "Invalid input"
      end
    end
  end

  def should_have_sent_contact_email
    Sidekiq::Worker.drain_all
    should have_sent_email_to(@petition_owner.email)
    should have_sent_email_to(@petition_admin.email)
  end

  def have_sent_email_to(user)
    have_sent_email.with_subject(/#{@email[:subject]}/i).from(@email[:from_address]).with_body(/#{@email[:content]}/i).to(user)
  end

end
