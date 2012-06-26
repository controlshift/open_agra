require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper
include EmailHelper


describe "Org admin moderates a petition'", type: :request, nip: true do
  before(:each) do
    @admin = Factory(:org_admin, organisation: @current_organisation)
    @user = Factory(:user, organisation: @admin.organisation)
    @petition = Factory(:petition, user: @user, organisation: @user.organisation)
    @signature = Factory(:signature, petition: @petition, join_organisation: true)
    @email = Factory(:petition_blast_email, petition: @petition)
    log_in(@admin.email, "onlyusknowit")
  end

  it "should be able to view an email" do
    visit org_path
    click_on "all-emails"
    page.should have_content("Blast Emails")
    click_on @email.subject
    page.should have_content(@email.subject)
    page.should have_content(@petition.title)
    page.should have_content(@email.body)

    select "Approved", from: "petition_blast_email_moderation_status"
    click_on 'moderate-email-submit'

    open_last_email
    current_email.subject.should == @email.subject

    @email.reload
    @email.moderated_at.should_not be_nil
    @email.moderation_status.should == 'approved'
  end
end
