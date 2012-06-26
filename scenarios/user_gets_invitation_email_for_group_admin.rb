require File.dirname(__FILE__) + '/scenario_helper.rb'
include LoginHelper

describe 'user gets invitation email to be a admin member of a group', type: :request, nip: :nip do
  before :each do
    @group = Factory(:group, organisation: @current_organisation)
    @invitation = Factory(:group_member, group: @group, user: nil)
    @invitation_link = group_invitation_url(@group, @invitation, token: @invitation.invitation_token)
  end

  it 'clicks on the invitation link' do
    clicks_on_the_invitation_link
    fill_and_submit_registration_form('Ruby', 'On Rails', @invitation.invitation_email, '123456')
    accepts_invitation
    sees_group_admin_page
  end

  def clicks_on_the_invitation_link
    visit @invitation_link
    current_url.should include(new_user_registration_url(email: @invitation.invitation_email))
  end

  def accepts_invitation
    page.should have_content('You have been invited to be an administrator')
    click_on 'Join Group'
  end

  def sees_group_admin_page
    page.current_url.should == group_manage_url(@group)
    page.should have_content('Ruby On Rails')
    page.should have_content(@group.title)
  end
end
