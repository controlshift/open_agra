require File.dirname(__FILE__) + '/scenario_helper.rb'

describe "user visit", :type => :request do
  before(:each) do
    @group = create(:group, organisation: @current_organisation)
    @petition = create(:petition, organisation: @current_organisation, group: @group)
  end

  context "group hub page through petition page" do
    it "should link to the petition group" do
      visit petition_path(@petition)

      page.find('.group-link').click

      page.should have_css(".group-title:contains('#{@group.title}')")
    end
  end
end
