require 'spec_helper'
describe Petitions::Comments::FlagsController do
  include_context "setup_default_organisation"

  before :each do
    @petition = Factory(:petition, :organisation => @organisation)
    @signature = Factory :signature, petition: @petition
  end

  context "an existing comment" do
    let(:comment) { Factory(:comment, :text => "this is a test comment", :signature => @signature, :flagged_at => nil) }

    describe '#create' do
      it "should be able to anonymously set the flag to true when captcha is valid" do
        controller.should_receive(:simple_captcha_valid?).and_return(true)
        post :create, :petition_id => @petition.slug, :comment_id => comment.id

        response.should be_success
        assigns[:comment].flagged?.should be_true
        assigns[:comment].flagged_by.should be_nil
      end

      context "signed in" do
        before(:each) do
          @user = FactoryGirl.create(:user, organisation: @organisation)
          sign_in @user
        end

        it "should allow a user to set the flag to true" do
          comment = Factory(:comment, :text => "this is a test comment", :signature => @signature, :flagged_at => nil )
          controller.should_receive(:simple_captcha_valid?).and_return(true)
          post :create, :petition_id => @petition.slug, :comment_id => comment.id

          response.should be_success
          assigns[:comment].flagged?.should be_true
          assigns[:comment].flagged_by.should == @user
        end

        it "should not allow a user to set the flag to true when captcha is invalid" do
          controller.should_receive(:simple_captcha_valid?).and_return(false)
          post :create, :petition_id => @petition.slug, :comment_id => comment.id


          response.should be_success
          assigns[:comment].flagged?.should be_false
          assigns[:comment].flagged_by.should be_nil
        end
      end

      it "should not be able to anonymously set the flag to true when captcha is invalid" do
        controller.should_receive(:simple_captcha_valid?).and_return(false)
        post :create, :petition_id => @petition.slug, :comment_id => comment.id

        response.should be_success
        assigns[:comment].flagged?.should be_false
        assigns[:comment].flagged_by.should be_nil
      end
    end

    describe "#new" do
      it "should render the captcha" do
        get :new, :petition_id => @petition.slug, :comment_id => comment.id

        response.should be_success
      end
    end
  end
end