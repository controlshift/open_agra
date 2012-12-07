require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe 'As group admin', type: :request do
  it 'should be able to send email to supporters of all petitions in a group' do
    org_admin = create(:org_admin, organisation: @current_organisation, confirmed_at: "2012-10-19 02:34:16")
    group = create(:group, organisation: @current_organisation)
    petition = create(:petition, organisation: @current_organisation, group: group)
    2.times do
      signature = create(:signature, petition: petition, join_organisation: true)
      group_signature = GroupSubscription.create(member: signature.member, group: group)
    end


    log_in(org_admin.email, 'onlyusknowit')

    visit group_manage_path(group)
    click_on 'create-group-blast-email'

    page.should have_content("2 subscribed supporters of the \"#{group.title}\" group")
    fill_in 'group_blast_email_subject', with: 'group blast email'
    fill_in 'group_blast_email[body]', with: 'group blast email content'
    click_on 'Send'

    current_path.should == group_manage_path(group)

    visit moderation_org_emails_path

    page.should have_css(".group_blast_email:contains('group blast email')")
  end
end
