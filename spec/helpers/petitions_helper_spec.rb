require 'spec_helper'

describe PetitionsHelper do
  self.use_transactional_fixtures = false

  describe "#body_text" do
    before(:each) do
      @user = FactoryGirl.build_stubbed(:user)
      @petition = FactoryGirl.build_stubbed(:petition, user: @user, slug: 'slug')
    end

    context "no current_user" do
      before(:each) do
        helper.stub(:current_user).and_return(nil)
      end

      it "should say 'signed' with no name if there is no current user" do
        text = helper.share_email_body_text(@petition)
        text.should include("signed the petition")
        strip_html_and_text_whitespace(text).should match /Thank you/
      end

    end

    context "current_user is petition creator" do
      before(:each) do
        helper.stub(:current_user).and_return(@user)
      end

      it "should say 'created' with the campaigner's name if the owner of the petition is logged in" do
        text = helper.share_email_body_text(@petition)
        text.should include("created the petition")
        strip_html_and_text_whitespace(text).should match /#{@user.first_name}/
      end
    end

    context "current user is another user" do
      before(:each) do
        @other = FactoryGirl.build_stubbed(:user)
        helper.stub(:current_user).and_return(@other)
      end

      it "should say 'signed' with the user's name if a user is logged in and not the creator of the petition" do
        text = helper.share_email_body_text(@petition)
        text.should include("signed the petition")
        strip_html_and_text_whitespace(text).should match /#{@other.first_name}/
      end
    end


    def strip_html_and_text_whitespace(str)
      str.gsub("&#x000A;", "").strip
    end
  end

  describe "#input_field" do
    before(:each) do
      @petition = FactoryGirl.build_stubbed(:petition, slug: 'slug')
      @effort = FactoryGirl.build_stubbed(:effort, title_label: 'title title', title_help: 'help help')
    end

    it "should return the correct form element string" do
      simple_form_for = mock('simple form')
      simple_form_for.should_receive(:input).with(:title, {:label => "title title", :input_html => {:value => @petition.title, :class => "span7", :rel => "popover", "data-title" => "title title", "data-content" => "help help"}}).and_return "html string"
      field = input_field_for_petition(simple_form_for, :title, "default title", "default help")
      field.should == 'html string'
    end

    it "should get the default value to the petition object if present" do
      @effort.title_default = "a default title"
      simple_form_for = mock('simple form')
      simple_form_for.should_receive(:input).with(:title, {:label => "title title", :input_html => {:value => @petition.title, :class => "span7", :rel => "popover", "data-title" => "title title", "data-content" => "help help"}}).and_return "html string"
      field = input_field_for_petition(simple_form_for, :title, "default title", "default help")
      field.should == 'html string'
    end

    it "should get the default value from the effort object if not present in petition" do
      @effort.title_default = "a default title"
      @petition.title = nil
      simple_form_for = mock('simple form')
      simple_form_for.should_receive(:input).with(:title, {:label => "title title", :input_html => {:value => "a default title", :class => "span7", :rel => "popover", "data-title" => "title title", "data-content" => "help help"}}).and_return "html string"
      field = input_field_for_petition(simple_form_for, :title, "default title", "default help")
      field.should == 'html string'
    end
  end

  describe "#twitter_share_href" do
    before :each do
      helper.stub(:cf).with('twitter_share_text').and_return("content")
    end

    let(:petition) { FactoryGirl.build_stubbed(:petition, organisation: organisation, id: 2, slug: 'slug') }

    context "organisation has twitter account" do
      let(:organisation) { FactoryGirl.build_stubbed(:organisation, host: 'ahost', twitter_account_name: "a_twitter_account", id: 1) }
      specify { helper.twitter_share_href(petition).should include("via=a_twitter_account") }
    end

    context "organisation has no twitter account" do
      let(:organisation) { FactoryGirl.build_stubbed(:organisation, twitter_account_name: nil, id: 1) }
      specify { helper.twitter_share_href(petition).should_not include("via=") }
    end
  end

  describe "link to edit user page by" do
    before(:each) do
      @organisation = FactoryGirl.build_stubbed(:organisation, id: 1)
      @org_admin = FactoryGirl.build_stubbed(:org_admin, organisation: @organisation)
      @user = FactoryGirl.build_stubbed(:user, organisation: @organisation)
      @petition = FactoryGirl.build_stubbed(:petition, user: @user, organisation: @organisation)
    end

    context "org admin" do
      before(:each) do
        helper.stub(:org_admin?).and_return(true)
        helper.stub(:admin?).and_return(false)
      end

      it "should link to edit org user page" do
        helper.link_to_edit_user(@petition.user).should include(edit_org_user_path(@petition.user))
      end
    end

    context "global admin" do
      before(:each) do
        helper.stub(:org_admin?).and_return(false)
        helper.stub(:admin?).and_return(true)
      end
      it "should link to edit admin user page" do
        helper.link_to_edit_user(@petition.user).should include(edit_admin_user_path(@petition.user))
      end
    end
  end

  describe "petition without user" do
    it "should show hyphen sign" do
      @petition = FactoryGirl.build_stubbed(:petition_without_leader, slug: 'slug')

      helper.link_to_edit_user(@petition.user).should == "-"
    end
  end

  context "petition chevron display" do
    before(:each) do
      helper.extend Haml
      helper.extend Haml::Helpers
      helper.send :init_haml_helpers
    end

    describe "#petition_chevron_for_edit_prompt_effort" do
      it "should return html string for edit prompt effort" do
        helper.petition_chevron_for_edit_prompt_effort.should have_content("Edit")
        helper.petition_chevron_for_edit_prompt_effort.should have_content("4")
      end
    end

    describe "#petition_chevron_for_normal_effort" do
      it "should return html string for normal effort" do
        helper.petition_chevron_for_normal_effort.should_not have_content("Edit")
      end
    end
  end

  context "facebook_share_href" do
    let(:petition) { FactoryGirl.build_stubbed(:petition, slug: 'slug') }
    it "should generate a link using the FacebookShare data" do
      variant = FactoryGirl.build_stubbed(:facebook_share_variant, petition: petition)
      petition.stub(:facebook_share_variants).and_return([variant])
      helper.facebook_share_href(petition).should =~ /facebook/
    end

    it "should default to the old behaviour if no share is present" do
      helper.facebook_share_href(petition).should =~ /facebook/
      helper.facebook_share_href(petition).should include('sharer.php?s=100&p[url]=')
    end

    it "should generate mobile compatible URL for mobile devices" do
      helper.stub(:is_mobile_device?).and_return(true)
      helper.facebook_share_href(petition).should include('sharer.php?u=')
    end
  end
end
