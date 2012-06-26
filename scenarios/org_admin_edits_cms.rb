require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe "Org admin edits cms", type: :request, nip: true do
  before(:each) do
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    log_in(@org_admin.email, "onlyusknowit")
  end

  it "should be able to edit the about us page." do
    @content = Factory(:content, slug: 'about_us', category: 'Footer', body: '<h1>About Us</h1>An about us page.', organisation: nil)
    visit about_us_path
    page.should_not have_content "Foo"
    page.should have_content 'About Us'

    click_on "#{@current_organisation.name} Admin"
    click_on "manage-contents"
    click_on 'Footer'
    click_on 'about_us-edit-link'

    fill_in "Body", with: "<h1>Foo</h1> we are all about that."
    click_on 'Save'
    current_url.should == org_contents_url
    page.should_not have_content 'problem'

    visit about_us_path
    page.should have_content "Foo"

    Content.find_by_slug_and_organisation_id('about_us', nil).should == @content
    Content.find_by_slug_and_organisation_id('about_us', @current_organisation).should_not be_nil
    
    # edit the existing content again
    visit edit_org_content_path(id: 'about_us' )

    fill_in "Body", with: "<h1>Bar</h1> we are all about that."
    click_on 'Save'
    current_url.should == org_contents_url
    page.should_not have_content 'problem'

    visit about_us_path
    page.should have_content "Bar"  
  end
end
