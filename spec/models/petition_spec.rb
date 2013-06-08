# == Schema Information
#
# Table name: petitions
#
#  id                           :integer         not null, primary key
#  title                        :string(255)
#  who                          :string(255)
#  why                          :text
#  what                         :text
#  created_at                   :datetime        not null
#  updated_at                   :datetime        not null
#  user_id                      :integer
#  slug                         :string(255)
#  organisation_id              :integer         not null
#  image_file_name              :string(255)
#  image_content_type           :string(255)
#  image_file_size              :integer
#  image_updated_at             :datetime
#  delivery_details             :text
#  cancelled                    :boolean         default(FALSE), not null
#  token                        :string(255)
#  admin_status                 :string(255)     default("unreviewed")
#  launched                     :boolean         default(FALSE), not null
#  campaigner_contactable       :boolean         default(TRUE)
#  admin_reason                 :text
#  administered_at              :datetime
#  effort_id                    :integer
#  admin_notes                  :text
#  source                       :string(255)
#  group_id                     :integer
#  location_id                  :integer
#  petition_letter_file_name    :string(255)
#  petition_letter_content_type :string(255)
#  petition_letter_file_size    :integer
#  petition_letter_updated_at   :datetime
#  alias                        :string(255)
#  achievements                 :text
#  bsd_constituent_group_id     :string(255)
#  target_id                    :integer
#  external_id                  :string(255)
#  redirect_to                  :text
#  external_facebook_page       :string(255)
#  external_site                :string(255)
#  show_progress_bar            :boolean         default(TRUE)
#  comments_updated_at          :datetime
#

require 'spec_helper'

describe Petition do
  context "a new petition object" do
    before(:each) do
      @petition = Petition.new
    end

    subject { @petition }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:who) }
    it { should validate_presence_of(:what) }
    it { should validate_presence_of(:why) }
    
    it { should ensure_length_of(:title).is_at_most(100) }
    it { should ensure_length_of(:who).is_at_most(240) }
    it { should ensure_length_of(:what).is_at_most(5000) }
    it { should ensure_length_of(:why).is_at_most(5000) }
    it { should ensure_length_of(:delivery_details).is_at_most(500)}
    it { should ensure_length_of(:alias).is_at_most(255) }

    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:who) }
    it { should allow_mass_assignment_of(:what) }
    it { should allow_mass_assignment_of(:why) }
    it { should allow_mass_assignment_of(:delivery_details)}

    it { should belong_to :location }

    describe "target association" do
      it { should belong_to(:target) }

      describe "validations" do
        it "should pass if there is no effort or target" do
          subject.should have(0).errors_on(:target)
        end

        it "should fail if specific_target? effort is present" do
          subject.effort = Factory.build(:effort, effort_type: 'specific_targets')
          subject.should have(1).errors_on(:target)
        end

        it "should pass if effort is not specific target" do
          subject.effort = Factory.build(:effort, effort_type: 'open_ended')
          subject.should have(0).errors_on(:target)
        end

        it "should pass if specific_target? effort and targets are present" do
          subject.effort = Factory.build(:effort, effort_type: 'specific_targets')
          subject.target = Factory.build(:target)
          subject.should have(0).errors_on(:target)
        end
      end
    end

    describe "effort association" do
      it { should belong_to(:effort) }

      describe "validations" do
        it "should pass if effort is present without target" do
          subject.effort = FactoryGirl.build_stubbed(:effort)
          subject.should have(0).errors_on(:effort)
        end

        it "should pass if there is no effort or target" do
          subject.should have(0).errors_on(:effort)
        end

        it "should fail if target is present without effort" do
          subject.target = FactoryGirl.build_stubbed(:target)
          subject.should have(1).errors_on(:effort)
        end
      end
    end

    describe "#signatures_size" do
      it "should just return the signatures collection size" do
        subject.signatures.should_receive(:size).and_return 1
        subject.signatures_size.should == 1
      end
    end

    [:title, :who, :what, :why, :delivery_details].each do |attribute|
      it "should strip whitespace from #{attribute}" do
        subject.send("#{attribute}=", " string ")
        subject.valid?
        subject.send(attribute).should == "string"
      end
    end
    
    it "should reject titles that do not contain at least 3 letters/numbers" do
      should_not allow_value("a         ").for(:title)
      should_not allow_value('ab !!!!!!!!!!!').for(:title)
    end

    it "should allow titles that contain at least 3 letters/numbers" do
      should allow_value("f-one         ").for(:title)
      should allow_value('hello !!!!!!!!!!!').for(:title)
    end

    it "should find the tags in admin notes" do
      subject.admin_notes = '#awesome foo @bar #good'
      subject.admin_notes_tags.should == ['#awesome', '#good']
    end

    it "should find the tags in admin notes" do
      subject.admin_notes = '#awesome'
      subject.admin_notes_tags.should == ['#awesome']
    end

    it "should strip tags from admin notes" do
      subject.admin_notes = '#awesome foo @bar #good'
      subject.admin_notes_without_tags.should == ' foo @bar '
    end
    
    it { should allow_value("abc").for(:alias) }
    it { should allow_value("123").for(:alias) }
    it { should allow_value("abc-123").for(:alias) }
    it { should_not allow_value("abc-123-*").for(:alias) }

    describe "#flags_count" do
      it "returns 0 if no flags" do
        subject.flags_count.should == 0
      end

      context "a petition and flag" do
        before(:each) do
          @user = Factory(:user)
          @petition = Factory(:petition, user: @user, organisation: @user.organisation)
          @flag = Factory(:petition_flag, petition: @petition, user: @user)
        end

        it "returns 1 if 1 flags" do
          @petition.flags_count.should == 1
        end

        it "returns 1 if 1 flag and petition is edited" do
          @petition.admin_status = :edited
          @petition.save
          @petition.flags_count.should == 1
        end

        it "returns 0 if 1 flag but been reviewed after" do
          @petition.admin_status = :awesome
          @petition.save
          @petition.flags_count.should == 0
        end

        it "returns 1 if 2 flags but 1 after been reviewed" do
          @petition.admin_status = :awesome
          @petition.save
          Factory(:petition_flag, petition: @petition, user: Factory(:user, organisation: @user.organisation))
          @petition.flags_count.should == 1
        end
      end
    end

    describe "#admin_status" do
      it { should allow_value(:unreviewed).for(:admin_status) }
      it { should allow_value(:approved).for(:admin_status) }
      it { should allow_value(:good).for(:admin_status) }
      it { should allow_value(:awesome).for(:admin_status) }
      it { should allow_value(:suppressed).for(:admin_status) }
      it { should allow_value(:inappropriate).for(:admin_status) }
      it { should allow_value(:edited).for(:admin_status)}
      it { should allow_value(:edited_inappropriate).for(:admin_status)}
      it { should_not allow_value(nil).for(:admin_status) }
      it { should_not allow_value(:none).for(:admin_status) }
      
      it "should ensure admin_reason is not nil when petition is set to inappropriate" do
        @petition.admin_status.should == :unreviewed
        @petition.errors[:admin_reason].should be_empty

        @petition.admin_status = :inappropriate
        @petition.valid?
        @petition.errors[:admin_reason].should_not be_empty
      end

      it "should set default value" do
        @petition = Factory.build(:petition)
        @petition.admin_status.should == :unreviewed

        @petition.save!
        @petition.admin_status.should == :unreviewed
      end

      it "should convert from symbol to string on write" do
        @petition.should_receive(:write_attribute).with(:admin_status, "approved")
        @petition.admin_status = :approved
      end

      it "should convert from string to symbol on read" do
        @petition.stub!(:read_attribute).with(:admin_status).and_return("approved")
        @petition.admin_status.should == :approved
      end
    end

    describe "#update_admin_status" do
      context "unreviewed petition" do
        include_context "setup_stubbed_petition"

        [:title, :who, :what, :why, :delivery_details].each do |attribute|
          it "should keep petition unreviewed if #{attribute} has been changed" do
            @petition.send("#{attribute}=".intern, "changed")
            @petition.send(:set_admin_status)
            @petition.admin_status.should == :unreviewed
          end
        end

        it "should keep petition unreviewed if image has been changed" do
          @petition.image_updated_at = Time.now
          @petition.send(:set_admin_status)
          @petition.admin_status.should == :unreviewed
        end
      end
      
      context "appropriate petition" do
        before(:each) do
          organisation = FactoryGirl.build_stubbed(:organisation)
          @petition = FactoryGirl.build_stubbed(:petition, user: FactoryGirl.build_stubbed(:user, organisation: organisation),
                                         organisation: organisation,
                                         slug: 'slug',
                                         admin_status: 'approved')
        end

        [:title, :who, :what, :why, :delivery_details].each do |attribute|
          it "should mark petition edited if #{attribute} has been changed" do
            @petition.send("#{attribute}=".intern, "changed")
            @petition.send(:set_admin_status)
            @petition.admin_status.should == :edited
          end
        end

        it "should mark petition edited if image has been changed" do
          @petition.image_updated_at = Time.now
          @petition.send(:set_admin_status)
          @petition.admin_status.should == :edited
        end
      end

      context "prohibited petition" do
        before(:each) do
          organisation = FactoryGirl.build_stubbed(:organisation)
          @petition = FactoryGirl.build_stubbed(:petition, user: FactoryGirl.build_stubbed(:user, organisation: organisation),
                                         organisation: organisation,
                                         slug: 'slug',
                                         admin_status: 'approved')
          @petition.stub(:prohibited?).and_return(true)
        end

        [:title, :who, :what, :why, :delivery_details].each do |attribute|
          it "should mark petition edited inappropriate if #{attribute} has been changed" do
            @petition.send("#{attribute}=".intern, "changed")
            @petition.send(:set_admin_status)
            @petition.admin_status.should == :edited_inappropriate
          end
        end

        it "should mark petition edited inappropriate if image has been changed" do
          @petition.image_updated_at = Time.now
          @petition.send(:set_admin_status)
          @petition.admin_status.should == :edited_inappropriate
        end
      end
    end

    describe "#update_admin_attributes" do
      Petition::ADMINISTRATIVE_STATUSES.each do |status|
        if status != :unreviewed
          it "should set administered_at when status is #{status}" do
            petition = FactoryGirl.build(:petition, admin_status: status)
            petition.admin_reason = "reason" if status == :inappropriate
            petition.send(:update_admin_attributes)
            petition.administered_at.should_not be_nil
          end
        end
      end

      Petition::EDIT_STATUSES.push(:unreviewed).each do |status|
        it "should not set administered_at when status is #{status}" do
          petition = FactoryGirl.build_stubbed(:petition, admin_status: status)
          administrated_at_before_status_changed = petition.administered_at
          petition.send(:update_admin_attributes)
          petition.administered_at.should == administrated_at_before_status_changed
        end
      end
    end

    context "with a user" do
      before(:each) do
        @user = User.new(Factory.attributes_for(:user))
        subject.user = @user
      end

      describe "delegation" do
        specify { subject.email.should == @user.email }
        specify { subject.first_name.should == @user.first_name }
        specify { subject.last_name.should == @user.last_name  }
      end
    end

    describe "#prohibited?" do
      [:inappropriate, :edited_inappropriate].each do |status|
        it "should return true if admin status is #{status}" do
          subject.admin_status = status
          subject.prohibited?.should be_true
        end
      end

      [:unreviewed, :awesome, :good, :approved, :edited].each do |status|
        it "should return false if admin status is #{status}" do
          subject.admin_status = status
          subject.prohibited?.should be_false
        end
      end

      describe "keep behavior while persisting the object" do
        before(:each) do
          @petition.admin_status = :inappropriate
          @petition.save
        end
        specify{ @petition.prohibited?.should be_true}
      end

      describe "keep behavior while using a factory" do
        before(:each) do
          @petition = Factory(:inappropriate_petition)
        end
        specify do
          @petition.prohibited?.should be_true
        end
      end
    end

    describe "#generate_token" do
      it "should generate token" do
        @petition = FactoryGirl.build(:petition)
        @petition.token.should be_nil

        @petition.send(:generate_token)
        @petition.token.should_not be_nil
      end
    end
  end

  describe "attaching an image" do
    it { should_not validate_attachment_presence(:image) }
    it { should validate_attachment_content_type(:image).allowing('image/jpeg', 'image/png').rejecting('text/plain', 'text/xml') }

    it "copies specific paperclip errors to #image for SimpleForm integration" do
      petition = FactoryGirl.build_stubbed(:petition)
      petition.errors.add(:image_content_type, "must be an image file")
      petition.run_callbacks(:validation)
      petition.errors[:image].should == ["must be an image file"]
    end

    it "removes unreadable paperclip errors from #image" do
      petition = FactoryGirl.build_stubbed(:petition)
      petition.errors.add(:image, "/var/12sdfsdf.tmp no decode delegate found")
      petition.run_callbacks(:validation)
      petition.errors[:image].should == []
    end
  end

  describe "#awesome" do
    before(:each) do
      @current_org = Factory(:organisation)
      @user = FactoryGirl.build_stubbed(:user, organisation: @current_org)
    end

    it "should retrieve awesome petitions" do
      Factory(:petition, organisation: @current_org, user: @user, admin_status: 'unreviewed')
      Factory(:petition, organisation: @current_org, user: @user, admin_status: 'approved')
      Factory(:petition, organisation: @current_org, user: @user, admin_status: 'inappropriate', admin_reason: 'reason')
      Factory(:petition, organisation: @current_org, user: @user, admin_status: 'awesome')
      Factory(:petition_without_leader, organisation: @current_org, admin_status: 'awesome')
      Factory(:petition, organisation: @current_org, cancelled: true, admin_status: 'awesome')

      petitions = Petition.awesome
      petitions.count.should == 2
      petition = petitions.first
      petition.admin_status.should == :awesome
      petition.cancelled.should be_false
    end

    it "should not retrieve any petitions" do
      Petition.awesome.should be_empty
    end
  end

  describe "#hot" do
    before(:each) do
      @current_org = Factory(:organisation)
      @user = FactoryGirl.build_stubbed(:user, organisation: @current_org)
    end

    it "should retrieve hot petitions" do
      @hottest_petition = Factory(:petition, organisation: @current_org, user: @user)
      5.times { Factory(:signature, petition: @hottest_petition) }
      @third_hot_day_petition = Factory(:petition_without_leader, organisation: @current_org)
      1.times { Factory(:signature, created_at: Date.today, petition: @third_hot_day_petition) }
      #order of petition creation is deliberately not in sort order
      @second_hot_week_petition = Factory(:petition, organisation: @current_org, user: @user)
      2.times { Factory(:signature, created_at: Date.today, petition: @second_hot_week_petition) }
      1.times { Factory(:signature, created_at: 1.day.ago, petition: @second_hot_week_petition) }
      1.times { Factory(:signature, created_at: 2.days.ago, petition: @second_hot_week_petition) }
      1.times { Factory(:signature, created_at: 3.days.ago, petition: @second_hot_week_petition) }

      petitions = Petition.hot([@current_org])
      petitions.count.should == 3
      petitions[0].id.should == @hottest_petition.id
      petitions[1].id.should == @second_hot_week_petition.id
      petitions[2].id.should == @third_hot_day_petition.id
    end

    it "should not retrieve any petitions" do
      Petition.hot([@current_org]).should be_empty
    end

    it 'should retrieve hot petitions from many organisations' do
      petition = Factory(:petition, organisation: @current_org, user: Factory(:user, organisation: @current_org))
      Factory(:signature, petition: petition)

      second_organisation = Factory(:organisation)
      second_petition = Factory(:petition, organisation: second_organisation, user: Factory(:user, organisation: second_organisation))
      Factory(:signature, petition: second_petition)

      another_organisation = Factory(:organisation)
      another_petition = Factory(:petition, organisation: another_organisation, user: Factory(:user, organisation: another_organisation))
      Factory(:signature, petition: another_petition)

      Petition.hot([@current_org, second_organisation]).to_a.should =~ [petition, second_petition]
    end

    it 'should retrieve hot petitions from a specific group' do
      group_a = Factory(:group, organisation: @current_org)
      petition_a = Factory(:petition, organisation: @current_org, user: Factory(:user, organisation: @current_org), group: group_a)
      Factory(:signature, petition: petition_a)

      group_b = Factory(:group, organisation: @current_org)
      petition_b = Factory(:petition, organisation: @current_org, user: Factory(:user, organisation: @current_org), group: group_b)
      Factory(:signature, petition: petition_b)

      group_c = Factory(:group, organisation: @current_org)
      petition_c = Factory(:petition, organisation: @current_org, user: Factory(:user, organisation: @current_org), group: group_c)
      Factory(:signature, petition: petition_c)

      Petition.hot([@current_org], [group_a, group_b]).to_a.should =~ [petition_a, petition_b]
    end
  end

  describe "#awaiting_moderation" do
    before :each do
      @current_org = Factory(:organisation)
      @user = FactoryGirl.build_stubbed(:user, organisation: @current_org)
    end

    def petition_with_admin_status(admin_status)
      petition = Factory(:petition, organisation: @current_org, user: @user)
      petition.update_attribute(:admin_status, admin_status)
      petition
    end

    specify { Petition.awaiting_moderation(@current_org.id).should_not include petition_with_admin_status(:approved) }
    specify { Petition.awaiting_moderation(@current_org.id).should_not include petition_with_admin_status(:awesome) }
    specify { Petition.awaiting_moderation(@current_org.id).should_not include petition_with_admin_status(:inappropriate) }

    specify { Petition.awaiting_moderation(@current_org.id).should include petition_with_admin_status(:unreviewed) }
    specify { Petition.awaiting_moderation(@current_org.id).should include petition_with_admin_status(:edited) }
    specify { Petition.awaiting_moderation(@current_org.id).should include petition_with_admin_status(:edited_inappropriate) }

    it "should return petitions that belongs to own organisation" do
      other_org = Factory(:organisation)
      petition_self = Factory(:petition, organisation: @current_org, user: @user)
      petition_other = Factory(:petition, organisation: other_org, user: @user)

      awaiting = Petition.awaiting_moderation(@current_org.id)
      awaiting.should include(petition_self)
      awaiting.should_not include(petition_other)
    end
  end

  describe "#appropriate" do
    it "should retrieve awesome and good petitions with and without leader" do
      unreviewed = Factory(:petition, admin_status: :unreviewed)
      good = Factory(:petition, admin_status: :good)
      awesome = Factory(:petition, admin_status: :awesome)
      orphan_awesome = Factory(:petition_without_leader, admin_status: :awesome)
      approved = Factory(:petition, admin_status: :approved)
      inappropriate = Factory(:petition, admin_status: :inappropriate, admin_reason: "don't like it")
      cancelled = Factory(:cancelled_petition, admin_status: :approved)

      Petition.appropriate.all.should =~ [awesome, good, orphan_awesome]
    end
  end

  describe "#orphans" do
    include_context "setup_petition"

    it "should retrieve petitions which are not orphans" do
      orphan = Factory(:petition_without_leader)
      Petition.not_orphan.should_not include(orphan)
      Petition.not_orphan.should include(@petition)
      Petition.not_orphan.should have(1).item
    end
  end

  describe "#cached_signatures_size" do
    include_context "setup_petition"

    it "should calculate the signatures count" do
      @signature = Factory(:signature, petition: @petition)
      @petition.cached_signatures_size.should == 1
      @signature2 = Factory(:signature, petition: @petition)
      @petition.cached_signatures_size.should == 1
    end
  end

  describe "#cached_comments_size" do
    include_context "setup_petition"

    it "should calculate the comments count" do
      signature = Factory(:signature, petition: @petition)
      comment = Factory(:comment, signature: signature)
      @petition.cached_comments_size.should == 1
      signature2 = Factory(:signature, petition: @petition)
      comment2 = Factory(:comment, signature: signature2)
      @petition.cached_comments_size.should == 1
    end
  end
  describe "#admins" do
    include_context "setup_petition"

    it "should include the creator" do
      @petition.admins.should include(@petition.user)
    end

    describe "a campaign admin" do
      before(:each) do
        @user_2 = Factory(:user)
        Factory(:campaign_admin, petition: @petition, user: @user_2, invitation_email: @user_2.email)
      end

      it "should include both users" do
        @petition.admins.should include(@petition.user)
        @petition.admins.should include(@user_2)
      end
    end

    context "a campaign admin who has been invited but has not accepted" do
      before(:each) do
        Factory(:campaign_admin, petition: @petition, user: nil, invitation_email: "george@washington.com")
      end

      it "should include both users" do
        @petition.admins.should include(@petition.user)
        @petition.admins.size.should == 1
        @petition.admins.should_not include(nil)
      end
    end
  end


  describe "#create_with_params" do
    it "should work without an image" do
      attrs = {}
      attrs[:effort] = Factory(:specific_targets_effort,
        image_default_file_name: nil, image_default_content_type: nil, image_default_file_size: nil, image_default_updated_at: nil
      )
      attrs[:target] = Factory(:target, name: "target name")
      p = Petition.create_with_param(attrs)
      p.title.should == "specific targets effort title: target name"
      p.save.should == true
    end

    it "should work with an image" do
      attrs = {}
      attrs[:effort] = Factory(:specific_targets_effort,
        image_default_file_name: 'image.jpg',
        image_default_content_type: 'image/jpg',
        image_default_file_size: 1024,
        image_default_updated_at: Time.now
      )
      attrs[:target] = Factory(:target, name: "target name")
      p = Petition.create_with_param(attrs)
      p.title.should == "specific targets effort title: target name"
      p.save.should == true
    end
  end

  describe "achievements" do
    it "should get manage status if not all of the share actions is accomplished" do
      petition = build(:petition)
      petition.achievements[:share_on_facebook] = "1"
      petition.achievements[:share_with_friends_on_facebook] = "0"

      petition.progress.should == "manage"
    end

    it "should get share status when all of the share actions are accomplished" do
      petition = build(:petition)
      petition.achievements[:share_on_facebook] = "1"
      petition.achievements[:share_with_friends_on_facebook] = "1"
      petition.achievements[:share_on_twitter] = "1"
      petition.achievements[:share_via_email] = "1"


      petition.progress.should == "share"
    end
  end

  describe "signature counts by source" do
    include_context "setup_petition"

    before(:each) do
      @signature = Factory(:signature, petition: @petition, source: 'foo')
      @signature = Factory(:signature, petition: @petition, source: '')
    end

    it "should provide a hash of counts" do
      @petition.signature_counts_by_source.should == {'' => 1, 'foo' => 1}
    end
  end

  describe ".featured_petitions" do
    before(:each) do
      @organisation = Factory(:organisation)
    end

    it "should return the featured petitions" do
      Factory(:petition, organisation: @organisation, admin_status: :awesome)
      Factory(:petition_without_leader, organisation: @organisation, admin_status: :awesome)
      Petition.featured_homepage_petitions(@organisation).count.should == 2
    end

    it "should return the latest featured effort" do
      earlier_featured_petition = create(:effort, organisation: @organisation, featured: true)
      latest_featured_petition = create(:effort, organisation: @organisation, featured: true)
      Petition.featured_homepage_petitions(@organisation).should == [latest_featured_petition]
    end
  end

  describe "does not crop image attachment" do
    it "should not call reprocess for image" do
      petition = FactoryGirl.build(:petition)
      petition.should_not_receive(:reprocess_image).and_return(nil)
      petition.save!
    end
  end

  describe "recent comments" do
    before :each do
      @petition = FactoryGirl.create(:petition)
      4.times.each do |count|
        signature = FactoryGirl.create(:signature, :petition => @petition)
        Factory :comment, :text => "This is a test comment #{count}", :signature => signature, flagged_at: nil
      end
      FactoryGirl.create(:signature, :petition => @petition)
    end

    it "should be able to get recent 3 signatures that have comments" do
      @petition.recent_comments.size.should == 3
      @petition.recent_comments.last.text.should == "This is a test comment 1"
    end

    it "should be able to scroll through the rest of the comments" do
      @petition.recent_comments(3,3).size.should == 1
      @petition.recent_comments(3,3).first.text.should == "This is a test comment 0"
    end

    it "should not return flagged and unapproved comments if any" do
      signature = FactoryGirl.create(:signature, :petition => @petition)
      comment = Factory :comment, :text => "this comment should not come at the first place", :flagged_at => Time.now, signature: signature
      @petition.recent_comments.first.text.should_not == "this comment should not come at the first place"
      comment.approved = false
      comment.save!
      comment.reload
      @petition.recent_comments.first.text.should_not == "this comment should not come at the first place"
      comment.approved = true
      comment.save!
      @petition.recent_comments.first.text.should == "this comment should not come at the first place"
    end

    it "should return blank if the petition is prohibited" do
      @petition.admin_status = :inappropriate
      @petition.recent_comments.size.should == 0
    end

  end

  describe "all comments" do

    before :each do
      @petition = FactoryGirl.create(:petition)
      4.times.each do |count|
        signature = FactoryGirl.create(:signature, :petition => @petition)
        Factory :comment, :text => "This is a test comment #{count}", :signature => signature
      end
      FactoryGirl.create(:signature, :petition => @petition)
    end

    it "should return all comments" do
      @petition.comments.size.should == 4
      @petition.comments.first.text.should == "This is a test comment 3"
    end    
  end

  describe "#subscribed_signatures" do
    before :each do
      @petition = FactoryGirl.create(:petition)
      Factory :signature, petition: @petition, unsubscribe_at: nil, join_organisation: true
      Factory :signature, petition: @petition, unsubscribe_at: Time.now, join_organisation: true
      Factory :signature, petition: @petition, unsubscribe_at: nil, join_organisation: true, additional_fields: {"is_employee" => "1"}
      Factory :signature, petition: @petition, unsubscribe_at: nil, join_organisation: true, additional_fields: {"is_employee" => "0"}
    end

    it "should be able to get all subscribed signatures when scope is nil" do
      @petition.subscribed_signatures(nil).size.should == 3
    end

    it "should be able to get all subscribed signatures when scope is empty" do
      @petition.subscribed_signatures("").size.should == 3
    end

    it "should be able to get signatures according to the scope when scope is present" do
      @petition.subscribed_signatures("employees").size.should == 1
    end
  end

  describe "#comments_size" do
    it "should just return the visible comments collection size" do
      petition = Factory(:petition)
      first_signature = Factory(:signature, petition: petition)
      second_signature = Factory(:signature, petition: petition)
      comment_visible = Factory(:comment, signature: first_signature)
      comment_not_visible = Factory(:comment, signature: second_signature, flagged_at: Time.now)

      petition.comments_size.should == 1
    end
  end
end
