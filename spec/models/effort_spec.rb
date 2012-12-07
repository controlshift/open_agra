# == Schema Information
#
# Table name: efforts
#
#  id                              :integer         not null, primary key
#  organisation_id                 :integer
#  title                           :string(255)
#  slug                            :string(255)
#  description                     :text
#  gutter_text                     :text
#  title_help                      :text
#  title_label                     :string(255)
#  title_default                   :text
#  who_help                        :text
#  who_label                       :string(255)
#  who_default                     :text
#  what_help                       :text
#  what_label                      :string(255)
#  what_default                    :text
#  why_help                        :text
#  why_label                       :string(255)
#  why_default                     :text
#  created_at                      :datetime
#  updated_at                      :datetime
#  image_file_name                 :string(255)
#  image_content_type              :string(255)
#  image_file_size                 :integer
#  image_updated_at                :datetime
#  thanks_for_creating_email       :text
#  ask_for_location                :boolean
#  effort_type                     :string(255)     default("open_ended")
#  leader_duties_text              :text
#  how_this_works_text             :text
#  training_text                   :text
#  training_sidebar_text           :text
#  distance_limit                  :integer         default(100)
#  prompt_edit_individual_petition :boolean         default(FALSE)
#  featured                        :boolean         default(FALSE)
#  image_default_file_name         :string(255)
#  image_default_content_type      :string(255)
#  image_default_file_size         :integer
#  image_default_updated_at        :datetime
#  landing_page_welcome_text       :text
#

require 'spec_helper'

describe Effort do
  context 'open ended efforts' do
    before(:each) do
      @effort = Effort.new(title: 'title', effort_type: 'open_ended')
    end

    subject { @effort }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:organisation) }
    it { should_not validate_presence_of(:title_default) }
    it { should_not validate_presence_of(:what_default) }
    it { should_not validate_presence_of(:why_default) }
    it { should_not validate_presence_of(:leader_duties_text) }
    it { should_not validate_presence_of(:how_this_works_text) }
    it { should_not validate_presence_of(:training_text) }
    it { should_not validate_presence_of(:training_sidebar_text) }
    it { should_not validate_presence_of(:landing_page_welcome_text) }
    it { should validate_numericality_of(:distance_limit)}
  end

  context 'specific targets efforts' do
    before(:each) do
      @effort = Effort.new(effort_type: 'specific_targets')
    end

    subject { @effort }

    it { should validate_presence_of(:title_default) }
    it { should validate_presence_of(:what_default) }
    it { should validate_presence_of(:why_default) }
    it { should validate_presence_of(:leader_duties_text) }
    it { should validate_presence_of(:how_this_works_text) }
    it { should validate_presence_of(:training_text) }
    it { should validate_presence_of(:training_sidebar_text) }
    it { should_not validate_presence_of(:landing_page_welcome_text) }
  end

  describe '@create_from_params' do
    context 'create specific targets efforts' do
      before(:each) do
        @basic_params = Factory.attributes_for(:specific_targets_effort)
      end

      it 'should ignore who_default field' do
        advanced_param = {who_default: "unused"}
        params = @basic_params.merge(advanced_param)
        effort = Effort.create_from_params(params)
        effort.who_default.should be_nil
      end

      it 'should ask for location by default' do
        advanced_param = {ask_for_location: nil}
        params = @basic_params.merge(advanced_param)
        effort = Effort.create_from_params(params)
        effort.ask_for_location.should == true
      end

      it 'should always ask for location' do
        advanced_param = {ask_for_location: false}
        params = @basic_params.merge(advanced_param)
        effort = Effort.create_from_params(params)
        effort.ask_for_location.should == true
      end

      it 'should be able to create efforts with settings' do
        advanced_param = {thanks_for_creating_email: "thanks for creating",
                          leader_duties_text: "leader duties",
                          how_this_works_text: "how this works",
                          training_text: "training text",
                          training_sidebar_text: "training sidebar text",
                          landing_page_welcome_text: "landing page welcome text",
                          featured: true}
        params = @basic_params.merge(advanced_param)
        effort = Effort.create_from_params(params)
        effort.thanks_for_creating_email.should == "thanks for creating"
        effort.leader_duties_text.should == "leader duties"
        effort.how_this_works_text.should == "how this works"
        effort.training_text.should == "training text"
        effort.training_sidebar_text.should == "training sidebar text"
        effort.landing_page_welcome_text.should == "landing page welcome text"
        effort.featured.should be_true
      end

      it 'should have default value of false for featured field' do
        effort = Effort.create_from_params(@basic_params)
        effort.featured.should be_false
      end
    end

    context 'create open ended efforts' do
      before(:each) do
        @basic_params = Factory.attributes_for(:effort)
      end

      it 'should accept params which belongs to open ended effort' do
        advanced_params = {title_help: "unused", title_label: "unused", who_help: "unused", who_label: "unused",
                           who_default: "unused", what_label: "unused", what_help: "unused", why_label: "unused",
                           why_help: "unused", ask_for_location: false, featured: true}
        params = @basic_params.merge(advanced_params)
        effort = Effort.create_from_params(params)
        advanced_params.each do |key, val|
          effort.attributes[key.to_s].should_not be_nil
        end
        effort.ask_for_location.should be_false
        effort.featured.should be_true
      end

      it 'should ignore fields which only belong to specific target effort' do
        advanced_param = {leader_duties_text: "unused", how_this_works_text: "unused",
                          training_text: "unused", training_sidebar_text: "unused"}
        params = @basic_params.merge(advanced_param)
        effort = Effort.create_from_params(params)
        effort.leader_duties_text.should be_nil
        effort.how_this_works_text.should be_nil
        effort.training_text.should be_nil
        effort.training_sidebar_text.should be_nil
      end
    end
  end

  describe '#locate_petition' do
    it 'should locate the page on which a petition is' do
      effort = FactoryGirl.create(:specific_targets_effort)
      petition_on_second_page = stub_model(Petition)
      petition_on_first_page_one = stub_model(Petition)
      petition_on_first_page_two = stub_model(Petition)
      petitions = mock
      effort.stub(:petitions).and_return petitions
      petitions.stub(:order).with('created_at DESC').and_return petitions
      petitions.stub(:to_a).and_return [petition_on_first_page_one, petition_on_first_page_two, petition_on_second_page]
      page_size = 2
      expected_page_number = 2
      WillPaginate.stub(:per_page).and_return page_size

      effort.locate_petition(petition_on_second_page).should == expected_page_number
    end
  end

  describe 'validate length' do
    [:title, :slug, :title_label, :title_default, :who_label, :what_label, :why_label].each do |field|
      it { should ensure_length_of(field).is_at_most(255) }
    end
  end


  describe 'attaching an image' do
    it { should_not validate_attachment_presence(:image) }
    it { should validate_attachment_content_type(:image).allowing('image/png').rejecting('text/plain') }

    it 'copies specific paperclip errors to #image for SimpleForm integration' do
      effort = Factory.build(:effort)
      effort.errors.add(:image_content_type, 'must be an image file')
      effort.run_callbacks(:validation)
      effort.errors[:image].should == ['must be an image file']
    end

    it 'removes unreadable paperclip errors from #image' do
      effort = Factory.build(:effort)
      effort.errors.add(:image, '/var/12sdfsdf.tmp no decode delegate found')
      effort.run_callbacks(:validation)
      effort.errors[:image].should == []
    end
  end

  describe 'rendering content' do
    effort = Effort.new
    petition = Petition.new
    petition.title = 'A title'
    effort.thanks_for_creating_email = '{{ petition.title }}'
    effort.render(:thanks_for_creating_email, {'petition' => petition}).should == 'A title'
  end

  describe '#petition_locations' do
    before(:each) do
      @effort = create(:specific_targets_effort)
      @appropriate_petition_location = create(:location)
      create(:target_petition, effort: @effort, location: @appropriate_petition_location)
    end

    it 'should return locations of all appropriate petitions under an effort' do
      create(:inappropriate_petition, effort: @effort, location: create(:location), target: create(:target))

      @effort.petition_locations.should == [@appropriate_petition_location]
    end

    it 'should ignore petitions without location' do
      create(:target_petition, effort: @effort, location: nil)
      @effort.petition_locations.should == [@appropriate_petition_location]
    end
  end

  describe 'order petitions by location' do
    it 'should return petitions order by nearest' do
      effort = FactoryGirl.build(:specific_targets_effort)
      petitions = mock
      query = mock
      input_latitude = 2
      input_longitude = 2
      Queries::Petitions::EffortLocationQuery.stub(:new).and_return query
      query.should_receive(:execute!)
      query.stub(:petitions) { petitions }

      effort.order_petitions_by_location(location: {latitude: input_latitude, longitude: input_longitude}).should == petitions
    end

    it 'should return all appropriate petition without params' do
      effort = FactoryGirl.build(:specific_targets_effort)
      petitions = mock
      appropriate_petitions = mock
      effort.stub(:petitions).and_return petitions
      petitions.stub(:appropriate).and_return appropriate_petitions

      effort.order_petitions_by_location(nil).should == appropriate_petitions
    end
  end

  describe '#signatures_size' do
    it 'should return the signatures count across all petitions of an effort' do
      effort = FactoryGirl.create(:effort)
      petition1 = FactoryGirl.create(:petition, effort: effort)
      petition2 = FactoryGirl.create(:petition, effort: effort)
      petition1.stub(:cached_signatures_size).and_return(50)
      petition2.stub(:cached_signatures_size).and_return(40)
      effort.stub(:petitions).and_return([petition1, petition2])

      effort.signatures_size.should == 90
    end
  end

  describe 'create petition with target within effort' do
    it 'should create a new petition with target' do
      target = FactoryGirl.create(:target, name: "target name")
      effort = FactoryGirl.create(:specific_targets_effort, title_default: "title default", what_default: "what default", why_default: "why default", who_default: target.name)
      existing_petition = FactoryGirl.create(:petition, title: "title default: target name", what: "what default", why: "why default", who: target.name )

      new_petition = effort.create_petition_with_target(target)
      new_petition.save

      Petition.find_by_slug(existing_petition.slug).effort_id.should be_nil
      new_petition.effort_id.should == effort.id
      new_petition.target_id.should == target.id
    end

    it 'should create two different petitions when adding the same target to two different efforts with the same default title' do
      target = FactoryGirl.create(:target, name: "target name")
      effort1 = FactoryGirl.create(:specific_targets_effort, title_default: "title default")
      effort2 = FactoryGirl.create(:specific_targets_effort, title_default: "title default")

      petition1 = effort1.create_petition_with_target(target)
      petition1.save
      petition2 = effort2.create_petition_with_target(target)
      petition2.save

      petition1.slug.should_not == petition2.slug
    end
  end

end
