require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe 'User searches petition within', type: :request, nip: true do
  context "specific target effort" do
    context "search from effort page" do
      before :each do
        @effort = FactoryGirl.create(:specific_targets_effort, organisation: @current_organisation, ask_for_location: true, distance_limit: nil)

        user = FactoryGirl.create(:user, organisation: @current_organisation)
        Factory(:target_petition, user: user, organisation: @current_organisation,
                location: FactoryGirl.create(:museum), effort: @effort)
        Factory(:target_petition, user: user, organisation: @current_organisation,
                location: FactoryGirl.create(:manly), effort: @effort)
        Petition.index
      end

      after :each do
        visit root_path
      end

      it 'searches', js: true do
        visit effort_path(@effort)

        page.should have_css('.thumbnails li div:contains("Manly")')
        page.should have_css('.thumbnails li div:contains("Museum")')

        fill_in 'location-query-field', with: 'Sydney, Australia'
        page.find('.search-effort').click

        page.should have_css('.thumbnails li:first-child div:contains("Museum")')

        fill_in 'location-query-field', with: 'Manly Beach, Sydney, Australia'
        page.find('.search-effort').click

        page.should have_css('.thumbnails li:first-child div:contains("Manly")')

      end

      it 'should be able to find petition without user', js: true do
        petition_without_user = Factory(:petition_without_leader, organisation: @current_organisation,
                                        location: FactoryGirl.create(:location, query: "1 main street, Chicago"),
                                        admin_status: :awesome, effort: @effort)

        Petition.index

        visit effort_path(@effort)
        page.should have_css('.thumbnails li div:contains("Chicago")')

        fill_in 'location-query-field', with: '1 main street, Chicago'
        page.find('.search-effort').click

        page.should have_css('.thumbnails li:first-child div:contains("Chicago")')
      end
    end

    context "search from effort near page" do
      before :each do
        @effort = FactoryGirl.create(:specific_targets_effort, organisation: @current_organisation, distance_limit: nil)
        location1 = FactoryGirl.create(:museum)
        location2 = FactoryGirl.create(:manly)
        target1 = FactoryGirl.create(:target, name: "museum_target", location: location1)
        target2 = FactoryGirl.create(:target, name: "manly_target", location: location2)

        user = FactoryGirl.create(:user, organisation: @current_organisation)
        FactoryGirl.create(:petition_without_leader, title: 'museum target petition', effort: @effort, location: location1,
                           target: target1, admin_status: :awesome, organisation: @current_organisation)
        FactoryGirl.create(:petition_without_leader, title: 'manly target petition', effort: @effort, location: location2,
                           target: target2, admin_status: :awesome, organisation: @current_organisation)
        Petition.index
      end

      it 'searches', js: true do
        visit new_effort_near_path(@effort)

        fill_in 'location-query-field', with: 'Sydney, Australia'
        page.find('.search-effort').click

        page.should have_css('#closest-petition :contains("museum_target")')
        page.should have_css('.nearby .nearby-petitions:contains("manly_target")')

        page.find('.accordion-toggle').click
        page.should have_css('.nearby .nearby-petitions .sign-nearby-petition')
      end

      it 'should be able to find petition without user', js: true do
        petition_without_user = Factory(:petition_without_leader, organisation: @current_organisation,
                                        location: FactoryGirl.create(:location, query: "1st street, Chicago"),
                                        admin_status: :awesome, effort: @effort)
        Petition.index

        visit new_effort_near_path(@effort)

        fill_in 'location-query-field', with: 'Chicago'
        page.find('.search-effort').click

        page.should have_css('#closest-petition :contains("1st street")')
        page.should have_css('.nearby .nearby-petitions:contains("manly_target")')

        page.find('.accordion-toggle').click
        page.should have_css('.nearby .nearby-petitions .sign-nearby-petition')
      end
    end

    it "sign petition" do
      effort = FactoryGirl.create(:specific_targets_effort, organisation: @current_organisation)
      petition = FactoryGirl.create(:petition_without_leader, title: 'museum target petition', effort: effort,
                                    admin_status: :awesome, organisation: @current_organisation)
      Petition.index

      visit effort_near_index_path(effort)
      click_on "sign-closest-petition"

      page.should have_css("h1", text: "museum target petition")
      sign_petition(petition.slug)

      visit effort_near_index_path(effort)
      page.should have_css(".signature-count .number", text: "1")
    end
  end
  context "open ended effort" do
    context "search from effort page" do
      before :each do
        @effort = FactoryGirl.create(:effort, organisation: @current_organisation, ask_for_location: true, distance_limit: nil)

        user = FactoryGirl.create(:user, organisation: @current_organisation)
        Factory(:petition, user: user, organisation: @current_organisation,
                location: FactoryGirl.create(:museum), admin_status: :awesome, effort: @effort)
        Factory(:petition, user: user, organisation: @current_organisation,
                location: FactoryGirl.create(:manly), admin_status: :awesome, effort: @effort)
        Petition.index
      end

      after :each do
        visit root_path
      end

      it 'searches', js: true do
        visit effort_path(@effort)

        page.should have_css('.thumbnails li div:contains("Manly")')
        page.should have_css('.thumbnails li div:contains("Museum")')

        fill_in 'location-query-field', with: 'Sydney, Australia'
        page.find('.search-effort').click

        page.should have_css('.thumbnails li:first-child div:contains("Museum")')

        fill_in 'location-query-field', with: 'Manly Beach, Sydney, Australia'
        page.find('.search-effort').click

        page.should have_css('.thumbnails li:first-child div:contains("Manly")')
      end
    end
  end
end
