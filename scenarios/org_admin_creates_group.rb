require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe "As Org admin", type: :request, nip: true do
  before(:each) do
    @user = Factory(:user, organisation: @current_organisation)
    @petition = Factory(:petition, title: 'test_petition', user: @user, organisation: @current_organisation)
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    log_in(@org_admin.email, 'onlyusknowit')
  end

  it "creates group with display opt-in", js: true do
    creates_new_group display_opt_in: true
    move_petition_to_group
    view_moved_petition_with_display_opt_in
  end

  it "creates group without display opt-in", js: true do
    creates_new_group display_opt_in: false
    move_petition_to_group
    view_moved_petition_without_display_opt_in
  end

  def creates_new_group(options)
    click_on "#{@current_organisation.name} Admin"
    click_on 'manage-groups'
    page.should_not have_content 'public view'

    click_on 'new-group'

    fill_in 'Title', with: 'Stand Up Affiliate'
    page.execute_script('tinyMCE.getInstanceById("group_description").setContent("Stand up is affiliated with Get Up")')

    if options[:display_opt_in]
      page.check 'group_display_opt_in'
      find('#group_opt_in_label').should be_visible
      fill_in 'Opt in label', with: 'You agree to this'
    else
      find('#group_opt_in_label').should_not be_visible
    end      
    click_on 'Save'
  end

  def move_petition_to_group
    click_on 'Move Petition Into Partnership'
    assert_modal_visible '#petition-modal'
    fill_in 'petition-slug-textbox', with: @petition.title
    click_on 'Confirm'
  end

  def view_moved_petition_with_display_opt_in
    click_on 'test_petition'
    find('input#signature_join_group').should be_visible
    page.should have_xpath '//label[@for="signature_join_group"]', text: 'You agree to this'
  end

  def view_moved_petition_without_display_opt_in
    click_on 'test_petition'
    find('input#signature_join_group').should_not be_visible
  end

  def assert_modal_visible modal_id
    wait_until { page.find(modal_id).visible? }
  rescue Capybara::TimeoutError
    flunk 'Expected modal to be visible.'
  end
end
