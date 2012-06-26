require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe 'As Org admin', type: :request, nip: true do
  before(:each) do
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    log_in(@org_admin.email, 'onlyusknowit')
  end

  it 'administers groups' do
    creates_new_group
    sends_invitation_to_someone
  end

  def creates_new_group
    click_on "#{@current_organisation.name} Admin"
    click_on 'manage-groups'
    current_path.should == org_groups_path
    page.should_not have_content 'public view'

    click_on 'new-group'

    fill_in 'Title', with: 'Stand Up Affiliate'
    fill_in 'Description', with: 'Stand up is affiliated with Get Up'
    click_on 'Save'

  end

  def sends_invitation_to_someone
    click_on 'group-admin-users'
    fill_in 'group_member_invitation_email', with: @org_admin.email
    click_on 'Send invitation'
    page.should have_content "Invitation has been sent to #{@org_admin.email}"
  end
end
