module StoryHelper
  def org_admin_creates_featured_story(title = "Story Title", content = "Story Content", image_path = "scenarios/fixtures/white.jpg")
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    log_in(@org_admin.email, "onlyusknowit")
    
    visit new_org_contents_story_path
    
    check "Featured"
    fill_in "Title", with: title
    fill_in "Content", with: content
    attach_file :image, Rails.root.join(image_path)
    click_on "Save"
    
    log_out
  end
end