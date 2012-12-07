require File.dirname(__FILE__) + '/scenario_helper.rb'

include PetitionHelper

describe "user visit", :type => :request do
  context "specific target effort" do
    before(:each) do
      @effort = FactoryGirl.create(:specific_targets_effort, organisation: @current_organisation)
      admin = FactoryGirl.create(:admin, organisation: @current_organisation)
      @petition1 = FactoryGirl.create(:target_petition, effort: @effort, user: admin, organisation: @current_organisation)
      @petition2 = FactoryGirl.create(:target_petition, effort: @effort, user: admin, organisation: @current_organisation)
    end

    context "landing page" do
      it "should show the campaigner signatures count and goal of this effort" do
        sign_petition(@petition1.slug)
        sign_petition(@petition2.slug)

        visit new_effort_near_path(@effort)

        page.should have_css(".progressbar .signature-count:contains('2')")
      end
    end

    context "hub page through petition page" do
      it "should link to the petition effort" do
        visit petition_path(@petition1)

        page.find('.effort-link').click

        page.should have_css(".effort-title:contains('#{@effort.title}')")
      end

      context "when petition belongs to both effort and group" do
        it "should only link to the petition effort" do
          group = create(:group, organisation: @current_organisation)
          @petition1.group = group
          @petition1.save

          visit petition_path(@petition1)

          page.should have_no_css('.group-link')
          page.find('.effort-link').click

          page.should have_css(".effort-title:contains('#{@effort.title}')")
        end
      end
    end

    context "hub page" do
      it "should show signature progress bar and all petitions within the effort" do
        sign_petition(@petition1.slug)
        sign_petition(@petition2.slug)

        visit effort_path(@effort)

        page.should have_css(".progressbar .signature-count:contains('2')")
        page.should have_css(".featured-petitions:contains('#{@petition1.title}')")
        page.should have_css(".featured-petitions:contains('#{@petition2.title}')")
        page.should have_css(".featured-petitions .petition-count:contains('2')")
      end
    end
  end
end
