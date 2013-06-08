# == Schema Information
#
# Table name: organisations
#
#  id                           :integer         not null, primary key
#  name                         :string(255)
#  created_at                   :datetime        not null
#  updated_at                   :datetime        not null
#  slug                         :string(255)
#  host                         :string(255)
#  contact_email                :string(255)
#  parent_name                  :string(255)
#  admin_email                  :string(255)
#  google_analytics_tracking_id :string(255)
#  blog_link                    :string(255)
#  notification_url             :string(255)
#  sendgrid_username            :string(255)
#  sendgrid_password            :string(255)
#  campaigner_feedback_link     :string(255)
#  user_feedback_link           :string(255)
#  use_white_list               :boolean         default(FALSE)
#  parent_url                   :string(255)
#  facebook_url                 :string(255)
#  twitter_account_name         :string(255)
#  settings                     :text
#  uservoice_widget_link        :string(255)
#  placeholder_file_name        :string(255)
#  placeholder_content_type     :string(255)
#  placeholder_file_size        :integer
#  placeholder_updated_at       :datetime
#

require 'spec_helper'

describe Organisation do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:slug) }
  it { should validate_presence_of(:host) }
  it { should validate_presence_of(:contact_email) }
  it { should validate_presence_of(:admin_email) }

  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:slug) }
  it { should allow_mass_assignment_of(:host) }
  it { should allow_mass_assignment_of(:contact_email) }
  it { should allow_mass_assignment_of(:admin_email) }
  it { should allow_mass_assignment_of(:blog_link) }
  it { should allow_mass_assignment_of(:parent_name) }
  it { should allow_mass_assignment_of(:google_analytics_tracking_id) }
  it { should allow_mass_assignment_of(:notification_url) }
  it { should allow_mass_assignment_of(:sendgrid_username) }
  it { should allow_mass_assignment_of(:sendgrid_password) }
  it { should allow_mass_assignment_of(:campaigner_feedback_link) }
  it { should allow_mass_assignment_of(:user_feedback_link) }
  it { should allow_mass_assignment_of(:twitter_account_name) }
  it { should respond_to(:requires_user_confirmation_on_sign_up) }
  it { should allow_mass_assignment_of(:requires_user_confirmation_on_sign_up) }
  it { should allow_mass_assignment_of(:bsd_host) }
  it { should allow_mass_assignment_of(:bsd_api_id) }
  it { should allow_mass_assignment_of(:bsd_api_secret) }
  it { should allow_mass_assignment_of(:action_kit_host) }
  it { should allow_mass_assignment_of(:action_kit_username) }
  it { should allow_mass_assignment_of(:action_kit_password) }
  it { should allow_mass_assignment_of(:country)}
  it { should respond_to(:action_kit_host) }
  it { should respond_to(:action_kit_username) }
  it { should respond_to(:action_kit_password) }
  it { should respond_to(:requires_location_for_campaign) }
  it { should respond_to(:always_join_parent_org_when_sign_up) }
  it { should allow_mass_assignment_of(:uservoice_widget_link) }
  it { should allow_mass_assignment_of(:use_white_list) }
  it { should allow_mass_assignment_of(:show_petition_category_on_creation) }

  it { should have_many(:categories) }

  describe "find by host" do
    before :each do
      @organisation = Factory(:organisation, host: "www.example.com")
    end

    specify { Organisation.find_by_host("www.example.com").should == @organisation }
    specify { Organisation.find_by_host("www.EXAMPLE.com").should == @organisation }
  end

  context "with a saved organisation" do
    before(:each) { @organisation = Factory(:organisation)}
    it { should validate_uniqueness_of(:name)}
    it { should validate_uniqueness_of(:slug)}
    it { should validate_uniqueness_of(:host)}
  end

  context "an unsaved org" do
    before(:each) do
      @organisation = Organisation.new
    end

    it "should not allow host to start with http" do
      should_not allow_value("http://www.google.com").for(:host)
    end

    it "should allow host to start without an http" do
      should allow_value("www.google.com").for(:host)
    end
  end

  it "should be able to get contact email with name" do
    organisation = Factory(:organisation, contact_email: "info@communityrun.org", name: "CommunityRun")
    organisation.contact_email_with_name.should == "\"CommunityRun\" <info@communityrun.org>"
  end

  describe "sendgrid credential" do
    it "should return org sendgrid username if exists" do
      subject.sendgrid_username = "my_username"
      subject.sendgrid_username.should == "my_username"
    end

    it "should return default sendgrid username if not exists" do
      ENV['SENDGRID_USERNAME'] = "default_username"
      subject.sendgrid_username.should == "default_username"
    end

    it "should return default sendgrid username if empty string" do
      ENV['SENDGRID_USERNAME'] = "default_username"
      subject.sendgrid_username = ""
      subject.sendgrid_username.should == "default_username"
    end

    it "should return org sendgrid password if exists" do
      subject.sendgrid_password = "my_password"
      subject.sendgrid_password.should == "my_password"
    end

    it "should return default sendgrid password if not exists" do
      ENV['SENDGRID_PASSWORD'] = "default_password"
      subject.sendgrid_password.should == "default_password"
    end

    it "should return default sendgrid password if empty string" do
      ENV['SENDGRID_PASSWORD'] = "default_password"
      subject.sendgrid_password = ""
      subject.sendgrid_password.should == "default_password"
    end
  end

  describe "#combined_name" do
    before(:each) { subject.name = 'foo' }
    it "should render a combination" do
      subject.parent_name = 'bar'
      subject.combined_name.should == 'foo and bar'
    end

    it "should render a non existing parent" do
      subject.parent_name = nil
      subject.combined_name.should == 'foo'
    end

    it "should render the long_name if present" do
      subject.name = 'Foo by Bar'
      subject.combined_name.should == 'Foo by Bar'
    end
  end

  describe '#requires_location_for_campaign?' do
    it 'should return true if requires location for campaign' do
      subject.requires_location_for_campaign = '1'
      subject.requires_location_for_campaign?.should be_true
    end

    it 'should return false if does not require location for campaign' do
      subject.requires_location_for_campaign = '0'
      subject.requires_location_for_campaign?.should be_false
    end
  end

  describe '#always_join_parent_org_when_sign_up?' do
    it 'should return true if always join parent org when sign up' do
      subject.always_join_parent_org_when_sign_up = '1'
      subject.always_join_parent_org_when_sign_up?.should be_true
    end

    it 'should return false if join parent org is optional' do
      subject.always_join_parent_org_when_sign_up = '0'
      subject.always_join_parent_org_when_sign_up?.should be_false
    end
  end

  describe "#cached_signatures_size" do
    it "should calculate the count" do
      @organisation = Factory(:organisation)
      @petition = Factory(:petition, organisation: @organisation)
      @signature = Factory(:signature, petition: @petition)
      @organisation.cached_signatures_size.should == 1
      @signature2 = Factory(:signature, petition: @petition)
      @organisation.cached_signatures_size.should == 1
    end
  end

  describe "attaching a placeholder image" do
    it { should_not validate_attachment_presence(:placeholder) }
    it { should validate_attachment_content_type(:placeholder).allowing('image/jpeg', 'image/png').rejecting('text/plain', 'text/xml') }

    it "copies specific paperclip errors to #image for SimpleForm integration" do
      organisation = FactoryGirl.build_stubbed(:organisation)
      organisation.errors.add(:placeholder_content_type, "must be an image file")
      organisation.run_callbacks(:validation)
      organisation.errors[:placeholder].should == ["must be an image file"]
    end

    it "removes unreadable paperclip errors from #image" do
      organisation = FactoryGirl.build_stubbed(:organisation)
      organisation.errors.add(:placeholder, "/var/12sdfsdf.tmp no decode delegate found")
      organisation.run_callbacks(:validation)
      organisation.errors[:placeholder].should == []
    end
  end

  describe "restrict auth scope to only fields required" do
    it "should not ask for fields that this organisation does not use" do
      subject.stub(:slug).and_return('foo')
      subject.facebook_auth_scope.should == 'email, publish_stream'
    end

    it "should include employer for coworker" do
      subject.stub(:slug).and_return('coworker')
      subject.facebook_auth_scope.should == 'email, publish_stream, friends_work_history, user_work_history'
    end
  end
end
