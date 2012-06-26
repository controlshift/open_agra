require 'spec_helper'

describe PetitionsHelper do
  include Devise::TestHelpers

  describe "#body_text" do
    before(:each) do
      @petition = Factory(:petition)
    end

    it "should say 'signed' with no name if there is no current user" do
      text = helper.share_email_body_text(@petition)
      text.should include("signed the petition")
      strip_html_and_text_whitespace(text).end_with?("Thank you!").should == true
    end

    it "should say 'created' with the campaigner's name if the owner of the petition is logged in" do
      petition_owner = @petition.user
      sign_in petition_owner
      text = helper.share_email_body_text(@petition)
      text.should include("created the petition")
      strip_html_and_text_whitespace(text).end_with?(petition_owner.first_name).should == true
    end

    it "should say 'signed' with the user's name if a user is logged in and not the creator of the petition" do
      user = Factory(:user)
      sign_in user
      text = helper.share_email_body_text(@petition)
      text.should include("signed the petition")
      strip_html_and_text_whitespace(text).end_with?(user.first_name).should == true
    end

    def strip_html_and_text_whitespace(str)
      str.gsub("&#x000A;", "").strip
    end

  end

  describe "#input_field" do
    before(:each) do
      @petition = Factory.build(:petition)
      @effort = Factory.build(:effort, title_label: 'title title', title_help: 'help help')
    end

    it "should return the correct form element string" do
      simple_form_for = mock('simple form')
      simple_form_for.should_receive(:input).with(:title, {:label=>"title title",  :input_html=>{:value=>@petition.title, :class=>"span7", :rel=>"popover", "data-title"=>"title title", "data-content"=>"help help"}}).and_return "html string"
      field = input_field(simple_form_for, :title, "default title",  "default help")
      field.should == 'html string'
    end

    it "should get the default value to the petition object if present" do
      @effort.title_default = "a default title"
      simple_form_for = mock('simple form')
      simple_form_for.should_receive(:input).with(:title, {:label=>"title title",  :input_html=>{:value=>@petition.title, :class=>"span7", :rel=>"popover", "data-title"=>"title title", "data-content"=>"help help"}}).and_return "html string"
      field = input_field(simple_form_for, :title, "default title",  "default help")
      field.should == 'html string'
    end

    it "should get the default value from the effort object if not present in petition" do
      @effort.title_default = "a default title"
      @petition.title = nil
      simple_form_for = mock('simple form')
      simple_form_for.should_receive(:input).with(:title, {:label=>"title title",  :input_html=>{:value=>"a default title", :class=>"span7", :rel=>"popover", "data-title"=>"title title", "data-content"=>"help help"}}).and_return "html string"
      field = input_field(simple_form_for, :title, "default title",  "default help")
      field.should == 'html string'
    end
  end

  describe "#twitter_share_href" do
    before :each do
      helper.stub(:cf).with('twitter_share_text').and_return("content")
    end

    context "organisation has twitter account" do
      let(:organisation) {Factory(:organisation, host: 'ahost', twitter_account_name: "a_twitter_account")}
      let(:petition) {Factory(:petition, organisation: organisation)}

      specify { helper.twitter_share_href(petition).should include("via=a_twitter_account") }
    end

    context "organisation has no twitter account" do
      let(:organisation) {Factory(:organisation, twitter_account_name: nil)}
      let(:petition) {Factory(:petition, organisation: organisation)}
      specify { helper.twitter_share_href(petition).should_not include("via=") }
    end
  end


end
