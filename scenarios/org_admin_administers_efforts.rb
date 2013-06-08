require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe 'Org admin', type: :request do
  before(:each) do
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    log_in(@org_admin.email, "onlyusknowit")
    SeedFu.seed
  end

  context 'create and edit' do
    it 'open ended effort', js: true do
      click_on "#{@current_organisation.name} Admin"
      click_on "all-landing-pages"
      click_on "New Landing Page"
      satisfy_effort_basic_info

      click_on "Save"
      page.should have_content("Effort name")

      click_on "edit-effort"
      fill_in "effort_title", with: "Another Name"
      click_on "Save"

      page.should_not have_content("Effort name")
      page.should have_content("Another Name")
    end

    it 'specific targets effort', js: true do
      visit new_org_effort_path()

      satisfy_specific_target_effort_info
      attach_file :image, Rails.root.join("scenarios/fixtures/black.jpg")


      click_on "Save Effort"
      page.should have_content("Effort name")
      page.should have_content("Add Target")

      click_on "edit-effort"

      visit effort_path("effort-name")
      page.should have_css(".effort-image img[alt='Black']")
    end
  end

  context 'administrate' do
    context 'open-ended effort' do
      before(:each) do
        @effort = Factory(:effort, organisation: @current_organisation)
      end

      it 'should list efforts' do
        click_on "#{@current_organisation.name} Admin"
        click_on "all-efforts"

        # this is a landing page, not an effort.
        page.should_not have_content(@effort.title)

        # now go to the landing page listing.
        click_on "all-landing-pages"

        page.should have_content(@effort.title)
        click_on @effort.title

        page.should have_content(@effort.title)
        click_on 'view-effort-button'

        page.should have_content(@effort.title)
        page.should have_content('Start A Campaign')
      end

      it 'should set default categories for the petitions within the effort', js: true do
        category = create(:category, name: "Environment", organisation: @current_organisation)
        CategorizedEffort.create!(effort: @effort, category: category)

        visit new_effort_petition_path(@effort)

        fill_in_petition("No more pokies", "who", "what", "why")
        click_on "Save"
        click_on "Next"
        click_on "View"

        page.should have_css(".title:contains('No more pokies')")
        page.should have_css(".petition-text:contains('Environment')")
      end
    end

    context 'specific target efforts' do
      it 'should expand advanced options by default', js: true do
        @effort = Factory(:specific_targets_effort, organisation: @current_organisation)
        visit org_effort_path(@effort)

        click_on "edit-effort"

        page.find("#effort_title_default").should be_visible
      end

      it 'should create an effort prompts leader to edit petition in it' do
        effort = create_prompt_edit_effort
        prepare_petition_within_effort(effort)

        visit effort_near_index_path(effort)
        page.find("#closest-petition .lead-petition-btn").click
        click_on "Commit as a Leader"
        click_on "I'm Ready, Let's Go!"

        page.should have_css(".edit")

        new_what_content = "new petition what"
        new_why_content = "new petition why"
        fill_in "petition_what", with: new_what_content
        fill_in "petition_why", with: new_why_content
        click_on "Save"

        click_on "view-petition-button"

        page.should have_css(".petition-text .what:contains('#{new_what_content}')")
        page.should have_css(".petition-text .why:contains('#{new_why_content}')")
      end

      it 'should create petition with default image which is set when creating effort', js: true do
        visit new_org_effort_path

        satisfy_specific_target_effort_info
        attach_file 'default_image', Rails.root.join("scenarios/fixtures/white.jpg")
        click_on "Save Effort"

        add_target
        click_on "Title default: Target name"

        page.should have_css(".title:contains('Title default: Target name')")
        page.find(".petition-image img")[:src].should match "white.jpg"
      end

      it 'should set default categories for the petitions within the effort', js: true do
        create(:category, name: "Environment", organisation: @current_organisation)
        visit new_org_effort_path

        satisfy_specific_target_effort_info
        check "Environment"
        click_on "Save Effort"

        add_target
        click_on "Title default: Target name"

        page.should have_css(".title:contains('Title default: Target name')")
        page.should have_css(".petition-text:contains('Environment')")
      end

      context 'on petition leaders page' do
        before(:each) do
          @effort = create(:specific_targets_effort, organisation: @current_organisation)
        end

        it 'should add admin notes for a petition' do
          petition = create(:target_petition, effort: @effort, organisation: @current_organisation)
          visit org_effort_leader_path(@effort, petition)

          fill_in 'petition_admin_notes', with: 'admin notes'
          click_on 'Save'

          visit org_effort_leader_path(@effort, petition)
          page.find('#petition_admin_notes').value.should include('admin notes')
        end

        it 'should see a table of the other campaign admins beyond the first leader' do
          petition = create(:target_petition, effort: @effort, organisation: @current_organisation)
          user = create(:user, organisation: @current_organisation)
          create(:campaign_admin, user: user, petition: petition, invitation_email: user.email)

          visit org_effort_leader_path(@effort, petition)

          page.should have_css(".campaign-admins #users :contains(\"#{user.full_name}\")")

          click_on('Manage Campaign Admins')

          page.should have_css("#campaign_admin_invitation_email")
        end

        it 'should see petition leading achievements' do
          petition = create(:petition_without_leader, effort: @effort, organisation: @current_organisation)
          visit effort_near_index_path(@effort)
          page.find("#closest-petition .lead-petition-btn").click
          click_on "Commit as a Leader"

          visit org_effort_leader_path(@effort, petition)

          page.should have_css(".lead-status.accomplished")
          page.should have_css(".training-status.unaccomplished")

          visit training_effort_petition_path(@effort, petition)
          click_on "I'm Ready, Let's Go!"

          visit org_effort_leader_path(@effort, petition)
          page.should have_css(".lead-status.accomplished")
          page.should have_css(".training-status.accomplished")
        end
      end

      it 'should set landing page welcome text under settings tab', js: true do
        visit new_org_effort_path

        satisfy_specific_target_effort_info
        page.find("#petition-settings-tab a").click()
        fill_in "effort_landing_page_welcome_text", with: "Welcome to this effort!"
        click_on "Save Effort"

        visit new_effort_near_path("effort-name")
        page.should have_css(".welcome-text:contains('Welcome to this effort!')")
      end
    end
  end
end

def create_prompt_edit_effort
  visit new_org_effort_path

  satisfy_specific_target_effort_info
  page.find("#petition-settings-tab a").click()
  check "effort_prompt_edit_individual_petition"

  click_on "Save Effort"
  page.should have_content("Effort name")

  Effort.first
end

def prepare_petition_within_effort(effort)
  petition = create(:petition_without_leader, organisation: @current_organisation)
  petition.effort = effort
  petition.save
end

def satisfy_specific_target_effort_info
  satisfy_effort_basic_info
end

def satisfy_effort_basic_info
  fill_in "effort_title", with: "Effort name"
  fill_in "Description", with: "Effort Description"
  fill_in "effort_title_default", with: "Title default"
  fill_in "What", with: "What default"
  fill_in "Why", with: "Why default"
end

def add_target
  click_on "Add Target"
  fill_in "Name", with: "Target name"
  click_on "Add Target"
  fill_in "location-query-field", with: "Sydney"
  click_on "Save"
end