# == Schema Information
#
# Table name: petitions
#
#  id                     :integer         not null, primary key
#  title                  :string(255)
#  who                    :string(255)
#  why                    :text
#  what                   :text
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  user_id                :integer
#  slug                   :string(255)
#  organisation_id        :integer         not null
#  image_file_name        :string(255)
#  image_content_type     :string(255)
#  image_file_size        :integer
#  image_updated_at       :datetime
#  delivery_details       :text
#  cancelled              :boolean         default(FALSE), not null
#  token                  :string(255)
#  admin_status           :string(255)     default("unreviewed")
#  launched               :boolean         default(FALSE), not null
#  campaigner_contactable :boolean         default(TRUE)
#  admin_reason           :text
#  administered_at        :datetime
#  effort_id              :integer
#  admin_notes            :text
#  source                 :string(255)
#  group_id               :integer
#  location_id            :integer
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

        it "returns 2 if 3 flags but 2 after been reviewed" do
          @petition.admin_status = :awesome
          @petition.save
          Factory(:petition_flag, petition: @petition, user: Factory(:user, organisation: @user.organisation))
          Factory(:petition_flag, petition: @petition, user: Factory(:user, organisation: @user.organisation))
          @petition.flags_count.should == 2
        end
      end

      it "returns 2 if 3 flags but 2 after been reviewed and edited" do
        @user = Factory(:user)
        p = Factory(:petition, user: @user)
        Factory(:petition_flag, petition: p, user: @user)
        p.admin_status = :awesome
        p.save
        Factory(:petition_flag, petition: p, user: Factory(:user, organisation: @user.organisation))
        Factory(:petition_flag, petition: p, user: Factory(:user, organisation: @user.organisation))
        p.flags_count.should == 2

        p.admin_status = :edited
        p.save
        p.flags_count.should == 2
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
        before(:each) do
          organisation = Factory(:organisation)
          @petition = Factory(:petition, user: Factory(:user, organisation: organisation), organisation: organisation)
          @petition.update_attribute(:admin_status, :unreviewed)
        end

        [:title, :who, :what, :why, :delivery_details].each do |attribute|
          it "should keep petition unreviewed if #{attribute} has been changed" do
            @petition.update_attribute(attribute, "changed")
            @petition.admin_status.should == :unreviewed
          end
        end

        it "should keep petition unreviewed if image has been changed" do
          @petition.image_updated_at = Time.now
          save_petition_and_assert :unreviewed
        end
      end
      
      context "appropriate petition" do
        before(:each) do
          organisation = Factory(:organisation)
          @petition = Factory(:petition, user: Factory(:user,  organisation: organisation), organisation: organisation)
          @petition.update_attribute(:admin_status, :approved)
        end

        [:title, :who, :what, :why, :delivery_details].each do |attribute|
          it "should mark petition edited if #{attribute} has been changed" do
            @petition.update_attribute(attribute, "changed")
            @petition.admin_status.should == :edited
          end
        end

        it "should mark petition edited if image has been changed" do
          @petition.image_updated_at = Time.now
          save_petition_and_assert :edited
        end
      end

      context "prohibited petition" do
        before(:each) do
          organisation = Factory(:organisation)
          @petition = Factory(:petition, user: Factory(:user, organisation: organisation), organisation: organisation, admin_status: :inappropriate, admin_reason: "Bad")
          @petition.stub(:prohibited?).and_return(true)
        end

        [:title, :who, :what, :why, :delivery_details].each do |attribute|
          it "should mark petition edited inappropriate if #{attribute} has been changed" do
            @petition.update_attribute(attribute, "changed")
            @petition.admin_status.should == :edited_inappropriate
          end
        end

        it "should mark petition edited inappropriate if image has been changed" do
          @petition.image_updated_at = Time.now
          save_petition_and_assert :edited_inappropriate
        end
      end

      def save_petition_and_assert(expected_admin_status)
        @petition.save!
        @petition.admin_status.should == expected_admin_status
      end
    end

    describe "#update_admin_attributes" do

      Petition::ADMINISTRATIVE_STATUSES.each do |status|
        if status != :unreviewed
          it "should set administered_at when status is #{status}" do
            petition = Factory.build(:petition)
            petition.admin_status = status
            petition.admin_reason = "reason" if status == :inappropriate
            petition.save!
            petition.administered_at.should_not be_nil
          end
        end
      end

      Petition::EDIT_STATUSES.push(:unreviewed).each do |status|
        it "should not set administered_at when status is #{status}" do
          petition = Factory.build(:petition)
          administrated_at_before_status_changed = petition.administered_at
          petition.admin_status = status
          petition.save!
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
          @petition.admin_status = status
          @petition.prohibited?.should be_true
        end
      end

      [:unreviewed, :awesome, :good, :approved, :edited].each do |status|
        it "should return false if admin status is #{status}" do
          @petition.admin_status = status
          @petition.prohibited?.should be_false
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
        @petition = Factory.build(:petition)
        @petition.token.should be_nil

        @petition.save!
        @petition.token.should_not be_nil
      end
    end

    describe "#find_by_token" do
      it "should find by token" do
        @petition = Factory(:petition)

        token = @petition.token

        Petition.find_by_token(token).id.should == @petition.id
      end

      it "should return nil petition if token is nil" do
        Petition.find_by_token(nil).should be_nil
      end
    end

    describe "#find_by_token!" do
      it "should find by token" do
        @petition = Factory(:petition)

        token = @petition.token

        Petition.find_by_token!(token).id.should == @petition.id
      end

      it "should raise exception if token is nil" do
        lambda {Petition.find_by_token!(nil)}.should raise_exception(ActiveRecord::RecordNotFound)
      end

      it "should raise exception if token is not found" do
        lambda {Petition.find_by_token!("unfound_token")}.should raise_exception(ActiveRecord::RecordNotFound)
      end

    end

    describe "#goal" do

      specify {
        subject.stub(:cached_signatures_size).and_return(99)
        subject.goal.should == 100
      }

      specify {
        subject.stub(:cached_signatures_size).and_return(100)
        subject.goal.should == 200
      }

      specify {
        subject.stub(:cached_signatures_size).and_return(101)
        subject.goal.should == 200
      }

      specify {
        subject.stub(:cached_signatures_size).and_return(850)
        subject.goal.should == 1000
      }

      specify {
        subject.stub(:cached_signatures_size).and_return(1001)
        subject.goal.should == 2000
      }
    end
  end

  describe "#csv" do
    it "should generate a csv string with all the fields" do
      @petition = Factory(:petition)
      sign1 = Factory(:signature, petition: @petition)
      sign2 = Factory(:signature, petition: @petition)
      sign3 = Factory(:signature, petition: @petition)
      csv = @petition.to_csv

      csv.should == <<-eos
First name,Last name,Email,Phone number,Postcode
#{sign1.first_name},#{sign1.last_name},#{sign1.email},#{sign1.phone_number},#{sign1.postcode}
#{sign2.first_name},#{sign2.last_name},#{sign2.email},#{sign2.phone_number},#{sign2.postcode}
#{sign3.first_name},#{sign3.last_name},#{sign3.email},#{sign3.phone_number},#{sign3.postcode}
      eos
    end

    it "should generate a csv string with specific fields" do
      @petition = Factory(:petition)
      sign1 = Factory(:signature, petition: @petition)
      sign2 = Factory(:signature, petition: @petition)
      sign3 = Factory(:signature, petition: @petition)

      csv = @petition.to_csv([:first_name, :last_name])

      csv.should == <<-eos
First name,Last name
#{sign1.first_name},#{sign1.last_name}
#{sign2.first_name},#{sign2.last_name}
#{sign3.first_name},#{sign3.last_name}
      eos
    end

    it "should generate header-only csv string if no signatures" do
      @petition = Factory(:petition)

      @petition.to_csv.should == "First name,Last name,Email,Phone number,Postcode\n"
    end
  end

  describe "attaching an image" do
    it { should_not validate_attachment_presence(:image) }
    it { should validate_attachment_content_type(:image).allowing('image/jpeg', 'image/png').rejecting('text/plain', 'text/xml') }

    it "copies specific paperclip errors to #image for SimpleForm integration" do
      petition = Factory.stub(:petition)
      petition.errors.add(:image_content_type, "must be an image file")
      petition.run_callbacks(:validation)
      petition.errors[:image].should == ["must be an image file"]
    end

    it "removes unreadable paperclip errors from #image" do
      petition = Factory.stub(:petition)
      petition.errors.add(:image, "/var/12sdfsdf.tmp no decode delegate found")
      petition.run_callbacks(:validation)
      petition.errors[:image].should == []
    end
  end

  describe "#awesome" do
    before(:each) do
      @current_org = Factory(:organisation)
      @user = Factory(:user, organisation: @current_org)
    end

    it "should retrieve awesome petitions" do
      Factory(:petition, organisation: @current_org, user: @user).update_attribute(:admin_status, :unreviewed)
      Factory(:petition, organisation: @current_org, user: @user).update_attribute(:admin_status, :approved)
      Factory(:petition, organisation: @current_org, user: @user).update_attribute(:admin_status, :inappropriate)
      Factory(:petition, organisation: @current_org, user: @user).update_attribute(:admin_status, :awesome)
      Factory(:petition, organisation: @current_org, user: nil).update_attribute(:admin_status, :awesome)
      Factory(:petition, organisation: @current_org, cancelled: true).update_attribute(:admin_status, :awesome)

      petitions = Petition.awesome
      petitions.count.should == 1
      petition = petitions.first
      petition.admin_status.should == :awesome
      petition.user.should_not be_nil
      petition.cancelled.should be_false
    end

    it "should not retrieve any petitions" do
      Petition.awesome.should be_empty
    end
  end

  describe "#hot" do
    before(:each) do
      @current_org = Factory(:organisation)
      @user = Factory(:user, organisation: @current_org)
    end

    it "should retrieve hot petitions" do
      @hottest_petition = Factory(:petition, organisation: @current_org, user: @user)
      5.times { Factory(:signature, petition: @hottest_petition) }
      @third_hot_day_petition = Factory(:petition, organisation: @current_org, user: @user)
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

    it "should not return any orphans" do
      orphan = Factory(:petition, user: nil, organisation: @current_org)
      Factory(:signature, created_at: Date.today, petition: orphan)

      petition = Factory(:petition, organisation: @current_org)
      Factory(:signature, created_at: Date.today, petition: petition)

      hot_petitions = Petition.hot([@current_org])
      hot_petitions.should_not include(orphan)
      hot_petitions.should include(petition)
      hot_petitions.should have(1).item
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

  describe "#one_signature" do
    before :each do
      @petition = Factory(:petition)
    end

    it "should return petitions being signed once only" do
      Factory(:signature, petition: @petition)
      Petition.one_signature.should include(@petition)
    end

    it "should not return petitions being signed more than once" do
      2.times {Factory(:signature, petition: @petition)}
      Petition.one_signature.should_not include(@petition)
    end

    it "should not return any orphan" do
      orphan = Factory(:petition, user: nil)
      Factory(:signature, petition: orphan)
      Petition.one_signature.should_not include(orphan)
    end

    it "should not return any draft" do
      draft = Factory(:petition, launched: false)
      Factory(:signature, petition: draft)
      Petition.one_signature.should_not include(draft)
    end

    it "should not return any prohibited" do
      edited_inappropriate = Factory(:petition, admin_status: :edited_inappropriate, admin_reason: 'a reason')
      Factory(:signature, petition: edited_inappropriate)
      inappropriate = Factory(:petition, admin_status: :inappropriate, admin_reason: 'another reason')
      Factory(:signature, petition: inappropriate)
      Petition.one_signature.should_not include(edited_inappropriate)
      Petition.one_signature.should_not include(inappropriate)
    end

    it "should not return any cancelled" do
      cancelled = Factory(:petition, cancelled: true)
      Factory(:signature, petition: cancelled)
      Petition.one_signature.should_not include(cancelled)
    end

  end

  describe "#awaiting_moderation" do
    before :each do
      @current_org = Factory(:organisation)
    end

    def petition_with_admin_status(admin_status)
      petition = Factory(:petition, organisation: @current_org)
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
      petition_self = Factory(:petition, organisation: @current_org)
      petition_other = Factory(:petition, organisation: other_org)

      awaiting = Petition.awaiting_moderation(@current_org.id)
      awaiting.should include(petition_self)
      awaiting.should_not include(petition_other)
    end

    context "a petiton and an orphaned petition" do
      before(:each) do
        @orphan = Factory(:petition, organisation: @current_org, user: nil)
        @petition = Factory(:petition, organisation: @current_org)
      end

      it "should not return any orphans" do
        awaiting = Petition.awaiting_moderation(@current_org.id)

        awaiting.should_not include(@orphan)
        awaiting.should include(@petition)
        awaiting.should have(1).item
      end
    end
  end
  
  describe "#appropriate" do
    it "should retrieve awesome and good petitions" do
      unreviewed = Factory(:petition, admin_status: :unreviewed)
      good = Factory(:petition, admin_status: :good)
      awesome = Factory(:petition, admin_status: :awesome)
      approved = Factory(:petition, admin_status: :approved)
      inappropriate = Factory(:petition, admin_status: :inappropriate, admin_reason: "don't like it")
      
      Petition.appropriate.all.should =~ [awesome, good]
    end
    
    it "should not return any cancelled" do
      cancelled = Factory(:cancelled_petition, admin_status: :approved)
      Petition.appropriate.should_not include(cancelled)
    end
  end

  describe "#orphans" do
    it "should retrieve petitions which are not orphans" do
      orphan = Factory(:petition, user: nil)
      petition = Factory(:petition)
      Petition.not_orphan.should_not include(orphan)
      Petition.not_orphan.should include(petition)
      Petition.not_orphan.should have(1).item
    end
  end

  describe "#cached_signatures_size" do
    it "should calculate the count" do
      @petition = Factory(:petition)
      @signature = Factory(:signature, petition: @petition)
      @petition.cached_signatures_size.should == 1
      @signature2 = Factory(:signature, petition: @petition)
      @petition.cached_signatures_size.should == 1
    end
  end

  describe "#admins" do
    before(:each) do
      @petition = Factory(:petition)
    end

    it "should include the creator" do
      @petition.admins.should include(@petition.user)
    end

    describe "with campaign admins" do
      before(:each) do
        @user_2 = Factory(:user)
        Factory(:campaign_admin, petition: @petition, user: @user_2, invitation_email: @user_2.email)
      end

      it "should include both users" do
        @petition.admins.should include(@petition.user)
        @petition.admins.should include(@user_2)
      end
    end

  end
end
