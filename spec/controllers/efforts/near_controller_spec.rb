require 'spec_helper'

describe Efforts::NearController do
  include_context 'setup_default_organisation'

  before(:each) do
    @effort = create(:specific_targets_effort, organisation: @organisation)
    @location_attributes = attributes_for(:location)
    @location = Location.create(@location_attributes)
    Effort.should_receive(:find_by_slug!).and_return(@effort)
  end

  describe "#index" do
    context "effort has no petition" do
      before(:each) do
        get :index, effort_id: @effort, location: @location_attributes
      end

      it "should render near index page"  do
        response.should render_template :index
      end
    end

    context "closest petition has no leader" do
      before(:each) do
        closest_petition = create(:petition_without_leader, effort: @effort, location: @location, organisation: @organisation)
        @effort.stub(:order_petitions_by_location).and_return([closest_petition])
        get :index, effort_id: @effort, location: @location_attributes
      end

      it "should render near index page" do
        response.should render_template :index
      end
    end

    context "closest petition already has leader" do
      before(:each) do
        @closest_petition = create(:target_petition, effort: @effort, location: @location, organisation: @organisation)
        @effort.stub(:order_petitions_by_location).and_return([@closest_petition])

        get :index, effort_id: @effort, location: @location_attributes
      end

      it "should redirect to petition show page" do
        response.should redirect_to petition_path(@closest_petition)
      end
    end

  end
end