require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe "Org admin administers targets", :type => :request, :js => true do
  let(:why_field_content_of_effort) {'why'}
  let(:what_field_content_of_effort) {'what'}
  let(:target_name) {'target name'}

  before(:each) do
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    @effort = Factory(:specific_targets_effort, organisation: @current_organisation)
    log_in(@org_admin.email, "onlyusknowit")
  end

  def new_target
    visit org_effort_path(@effort.slug)
    click_on "Add Target"
    fill_in "Name", with: target_name
    click_on "Add Target"

    page.should have_css("#target_name[value='#{target_name}']")
  end

  def created_target
    page.should have_content("Created successfully!")
    page.should have_css("#petitions :contains('#{target_name}')")

    click_on "#{@effort.title_default}: #{target_name}"

    page.should have_css(".title:contains('#{@effort.title_default}: #{target_name}')")
    page.should have_css(".who:contains('#{target_name}')")
    page.should have_css(".why:contains('#{why_field_content_of_effort}')")
    page.should have_css(".what:contains('#{what_field_content_of_effort}')")
  end
  
  it 'generate new petition when you create a new target' do
    new_target

    fill_in "Phone Number", with: "12345678912"
    fill_in "Email", with: "abc@123.com"
    fill_in "location-query-field", with: "Sydney"
    click_on "Save"
    
    created_target
  end


  it 'should use the existing target when you creating a target' do
    FactoryGirl.create(:target_petition, organisation: @current_organisation, effort: @effort, target: FactoryGirl.create(:target, name: 'existing target', organisation: @current_organisation))

    visit org_effort_path(@effort.slug)
    click_on "Add Target"

    fill_in "Name", with: "existing target"
    click_on "Add Target"

    page.should have_css("#petitions :contains('existing target')")
  end

  it 'should create two different petitions when add the same target to two different efforts with the same name' do
    effort_default_title = "effort default title"
    target_name = "Hu Jintao"
    effort1 = Factory(:specific_targets_effort, title_default: effort_default_title, what_default: "first effort default what", organisation: @current_organisation)
    effort2 = Factory(:specific_targets_effort, title_default: effort_default_title, what_default: "second effort default what", organisation: @current_organisation)
    target = Factory(:target, name: target_name, organisation: @current_organisation)

    visit org_effort_path(effort1.slug)
    click_on "Add Target"
    fill_in "Name", with: target_name
    click_on "Add Target"
    click_on "#{effort_default_title}: #{target_name}"
    page.should have_css(".what:contains('first effort default what')")

    visit org_effort_path(effort2.slug)
    click_on "Add Target"
    fill_in "Name", with: target_name
    click_on "Add Target"
    click_on "#{effort_default_title}: #{target_name}"
    page.should have_css(".what:contains('second effort default what')")

    visit org_petitions_path
    page.should have_css(".petition", :text => "#{effort_default_title}: #{target_name}", :count => 2)

    visit org_effort_path(effort1.slug)
    click_on "#{effort_default_title}: #{target_name}"
    page.should have_css(".what:contains('first effort default what')")
  end

  it 'edit target' do
    FactoryGirl.create(:target_petition, organisation: @current_organisation, effort: @effort, target: FactoryGirl.create(:target, name: target_name, organisation: @current_organisation,))

    visit org_effort_path(@effort.slug)
    page.find('.edit-target').click

    page.should have_css("#target_name[disabled]")
    fill_in "Phone Number", with: "11122223333"
    fill_in "Email", with: "ttt@123.com"
    fill_in "location-query-field", with: "Beijing"
    click_on "Save"

    page.should have_css(".alert-success :contains('Edited #{target_name} successfully')")
    page.should have_css("#petitions .petition:contains('Beijing')")
  end

  it 'remove target' do
    FactoryGirl.create(:target_petition, organisation: @current_organisation, effort: @effort, target: FactoryGirl.create(:target, name: target_name, organisation: @current_organisation,))

    visit org_effort_path(@effort.slug)
    page.find('.remove-target').click

    page.should have_no_css("#petitions :contains('#{target_name}')")
  end
end
