require 'spec_helper'

describe Efforts::PetitionsController do
  before(:each) do
    @organisation = Factory(:organisation)
    @user = Factory(:user, organisation: @organisation)
    @effort = Factory(:effort, organisation: @organisation)
    controller.stub(:current_organisation).and_return(@organisation)
  end

  describe "#new" do
    before(:each) do
      get :new, effort_id: @effort.slug
    end

    it { should assign_to :effort }
    it { should assign_to :petition }
    it { should render_template :new }

    it "should make the petition have the right effort" do
      assigns(:petition).effort.should == @effort
    end
  end
end