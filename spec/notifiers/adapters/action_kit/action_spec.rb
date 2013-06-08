require 'spec_helper'

describe Adapters::ActionKit::Action do
  let(:organisation) {Factory(:organisation)}
  subject { Adapters::ActionKit::Action.new(petition: petition, user_details: user_details, organisation: organisation) }

  context "with real objects" do
    let(:petition) { Factory(:petition, organisation: organisation, external_id: '123')}
    let(:user_details) { Factory(:signature, petition: petition, postcode: '87105-3787')}

    describe "#to_hash" do
      let(:output) {
        {
            page: petition.external_id,
            first_name: user_details.first_name,
            last_name: user_details.last_name,
            email: user_details.email,
            zip: '87105-3787',
            created_at: user_details.created_at,
            country: 'US',
            list: '1',
            source: 'controlshift',
            home_phone: user_details.phone_number,
            action_categories: ['cat1'],
        }
      }

      before(:each) do
        subject.stub(:category_slugs).and_return(['cat1'])
      end

      context "an organisation with a custom field" do
        let(:organisation) { Factory(:organisation, action_kit_country: 'US', slug: 'fake') }

        it "should format the data" do
          subject.to_hash.should == output.merge({action_custom: 'a custom field'})
        end
      end

      context "a source" do
        let(:user_details) { Factory(:signature, petition: petition, postcode: '87105-3787', source: 'facebook')}
        it "should pass it on to ak" do
          subject.to_hash[:source].should == 'controlshift_facebook'
        end
      end

      context "an akid token" do
        let(:user_details) { Factory(:signature, petition: petition, postcode: '87105-3787', akid: '1234')}

        it "should pass it on to ak" do
          subject.to_hash[:referring_akid].should == '1234'
        end
      end

      context "no akid token" do
        let(:user_details) { Factory(:signature, petition: petition, postcode: '87105-3787', akid: nil)}

        it "should pass it on to ak" do
          subject.to_hash[:referring_akid].should be_nil
        end
      end

      context "an organisation without custom fields" do
        let(:organisation) { Factory(:organisation, action_kit_country: 'US', slug: 'no_slug') }

        it "should format the data" do
          subject.to_hash.should == output
        end

        context "with a user object instead of a signature" do
          let(:user_details) { Factory(:user, postcode: '87105-3787')}

          it "should format the data" do
            subject.to_hash.should == output
          end
        end
      end
    end
  end

  context "mocks" do
    let(:organisation) { mock() }
    let(:petition)     { mock() }
    let(:user_details) { mock() }

    describe "#format_postcode" do

      context "no country" do
        before(:each) do
          petition.stub(:location).and_return nil
          organisation.stub(:action_kit_country).and_return nil
        end

        specify do
          user_details.stub(:postcode).and_return('12345 -1234')
          subject.formatted_postcode.should == '12345-1234'
        end

        specify do
          user_details.stub(:postcode).and_return('123451234')
          subject.formatted_postcode.should == '12345-1234'
        end

        specify do
          user_details.stub(:postcode).and_return('12345 1234')
          subject.formatted_postcode.should == '12345-1234'
        end

        specify do
          user_details.stub(:postcode).and_return('12345-1234')
          subject.formatted_postcode.should == '12345-1234'
        end
        specify do
          user_details.stub(:postcode).and_return('02052')
          subject.formatted_postcode.should ==  '02052'
        end
        specify do
          user_details.stub(:postcode).and_return('12345 1234')
          subject.formatted_postcode.should == '12345-1234'
        end
        specify do
          user_details.stub(:postcode).and_return('1 2 3 4')
          subject.formatted_postcode.should == '1 2 3 4'
        end
      end
    end

    context "petition location" do
      before(:each) do
        petition.stub(:location).and_return(location = mock())
        location.stub(:country).and_return('AU')
        organisation.stub(:action_kit_country).and_return nil
        user_details.stub(:postcode).and_return('1 2 3 4')
      end

      specify { subject.formatted_postcode.should == '1234' }

      it "should return the postcode if it can not be formatted" do
        user_details.stub(:postcode).and_return('11238-1234')
        subject.formatted_postcode.should == '11238-1234'
      end
    end

    context "organisation location" do
      before(:each) do
        petition.stub(:location).and_return nil
        organisation.stub(:action_kit_country).and_return 'AU'
        user_details.stub(:postcode).and_return('1 2 3 4')
      end

      specify { subject.formatted_postcode.should == '1234' }
    end
  end
end