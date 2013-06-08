require 'spec_helper'

describe Petitions::NearController do
  include_context 'setup_default_organisation'

  before(:each) do
    @location_attributes = attributes_for(:location)
    @location = Location.create(@location_attributes)
    @petition = Factory(:petition, organisation: @organisation, location: @location)
    @category = Factory(:category, organisation: @organisation)
    @category2 = Factory(:category, organisation: @organisation)
  end

  describe "#new" do
    context "without a category" do
      before(:each) do
        get :new
      end

      it "should render near new page"  do
        response.should render_template :new
      end
      it "should assign all organisation categories"  do
        assigns[:categories].should == @organisation.categories
      end
    end
    context "with a category" do
      before(:each) do
        get :new, category: @category.slug
      end

      it "should render near new page"  do
        response.should render_template :new
      end
      it "should assign only one  category" do
        assigns[:categories].should == [@category]
      end
    end
    context "in an embed" do
      context "without a category" do
        before(:each) do
          get :new, :embed => 'true'
        end
        it "should render near embed page without a layout"  do
          response.should render_template :iframe, :layout => nil
        end
      end
      context "with a category" do
        before(:each) do
          get :new, :embed => 'true', category: @category.slug
        end
        it "should render near embed page without a layout"  do
          response.should render_template :iframe, :layout => nil
        end
      end
    end
  end

  describe "#index" do
    context "with a location" do
      before(:each) do
        @closest_petition = Factory(:petition, location: @location, organisation: @organisation)
        @organisation.stub(:order_petitions_by_location).and_return([@closest_petition])

        get :index, location: @location_attributes
      end

      it "should render near new page"  do
        response.should render_template :new
      end
      it "should assign the nearby petitions" do
        assigns[:petitions].should == [@closest_petition]
      end
    end

    context "with redirect params" do
      before(:each) do
        @closest_petition = Factory(:petition, location: @location, organisation: @organisation)
        @organisation.stub(:order_petitions_by_location).and_return([@closest_petition])

        get :index, location: @location_attributes, redirect: true
      end

      it "should redirect to petition show page" do
        response.should redirect_to petition_path(@closest_petition)
      end
    end

  end
end