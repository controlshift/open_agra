require 'spec_helper'

describe Petitions::CategoriesController do
  include_context "setup_default_organisation"

  context "signed in and a petition" do
    before(:each) do
      @user = Factory(:user, organisation: @organisation)
      @petition = Factory(:petition, user: @user, organisation: @organisation)
      sign_in @user
    end

    describe "#index" do
      it "should return an empty array" do
        get :show, petition_id: @petition.slug
        JSON.parse(response.body).should be_empty
      end

      context "with a category" do
        before(:each) do
          @category = Factory(:category, organisation: @organisation)
          CategorizedPetition.create(category: @category, petition: @petition)
        end

        it "should return the category" do
          get :show, petition_id: @petition.slug
          JSON.parse(response.body).should_not be_empty
        end
      end
    end

    describe "#update" do
      before(:each) do
        @category = Factory(:category, organisation: @organisation)
      end

      it "should add categories" do
        put :update, {petition_id: @petition.slug, "petition" => {"category_ids"=>[@category.id.to_s]}}
        JSON.parse(response.body).should_not be_empty
      end
    end
  end
end
