require 'spec_helper'

describe ActionKitNotifier do
  subject { ActionKitNotifier.new('localhost', 'username', 'password') }

  describe "initialisation" do
    specify { subject.ak.should be_an_instance_of(ActionKitRest::Client) }
    specify { subject.ak.username.should == 'username' }
    specify { subject.ak.password.should == 'password'}
    specify { subject.ak.host.should ==  'localhost'}
    it "should use the railtie to setup the logger" do
      ActionKitRest.logger.should == Rails.logger
    end
  end

  describe "#ensure_category_pages_present" do
    let(:petition) { Factory(:petition, organisation: organisation) }
    let(:organisation) { Factory(:organisation) }
    let(:category) { Factory(:category)}

    before(:each) do
      CategorizedPetition.create!(petition: petition, category: category)
      subject.petition = petition
      subject.organisation = organisation
    end

    it "should create a tag for the category" do
      petition.categories.should include(category)

      subject.ak.stub(:tag).and_return(tag = mock())
      tag.stub(:find_or_create).and_return(tag_obj = mock())
      tag_obj.stub(:name).and_return "category name"
      tag_obj.stub(:resource_uri).and_return '/rest/v1/tag/46/'


      subject.send(:ensure_category_pages_present).should == true
      category.reload.external_id.should == '46'
    end
  end

  describe "#notify_sign_up" do
    let(:organisation) { Factory(:organisation, action_kit_country: 'AU')}
    let(:petition) { Factory(:petition, organisation: organisation, external_id: 'page_petition') }
    before(:each) do
      petition.stub(:categories) { [OpenStruct.new(slug: 'cat1')] }
    end


    describe "success" do
      let(:data) {
        {
            page: 'page_petition',
            first_name: user_details.first_name,
            last_name: user_details.last_name,
            email: user_details.email,
            zip: '87105 3787',
            created_at: user_details.created_at,
            home_phone: user_details.phone_number,
            country: 'AU',
            list: '1',
            source: 'controlshift',
            action_categories: ['cat1']
        }
      }

      before(:each) do
        subject.should_receive(:ensure_external_petition_present).and_return true
        subject.should_receive(:ensure_creators_page_present).and_return true
        subject.should_receive(:ensure_category_pages_present).and_return true

        subject.stub(:ak).and_return(ak = mock)
        ak.stub(:action).and_return(action = mock())
        action.should_receive(:create).at_least(1).times.with(data).and_return(obj = mock())
        obj.stub(:user).and_return('/rest/v1/user/39520/')
        obj.stub(:id).and_return "123"
        obj.stub(:created_user).and_return true
      end

      context "with a user" do
        let(:user_details) { Factory(:user, postcode: '87105 3787', organisation: organisation) }

        it 'should create an action' do
          subject.notify_sign_up(user_details: user_details, petition: petition, organisation: organisation)

          user_details.reload
          user_details.external_constituent_id.should == '39520'
        end
      end

      context "with a signature" do
        let(:user_details) { Factory(:signature, postcode: '87105 3787', petition: petition) }

        it 'should create an action' do
          subject.notify_sign_up(user_details: user_details, petition: petition, organisation: organisation)

          user_details.reload
          user_details.external_constituent_id.should == '39520'
          user_details.external_id = '123'
          user_details.member.external_id = '39520'
        end
      end
    end

    it "should propagate raised exceptions" do
      subject.stub(:ensure_external_petition_present).and_return true
      subject.stub(:ensure_creators_page_present).and_return true
      subject.stub(:ensure_category_pages_present).and_return true

      ActionKitRest::Client.stub(:new).and_raise(Exception)
      lambda { subject.notify_sign_up(user_details: user, petition: petition, organisation: organisation) }.should raise_error
    end
  end
end