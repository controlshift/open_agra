require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include StoryHelper

describe "User visits home page", type: :request do

  it 'should see featured stories' do
    org_admin_creates_featured_story("First Story", "Some Content", "scenarios/fixtures/white.jpg")
    org_admin_creates_featured_story("Second Story", "More Content", "scenarios/fixtures/black.jpg")

    sees_featured_story
  end


  it 'should see featured effort' do
    create(:effort, organisation: @current_organisation, featured: true, title: "featured effort name")

    visit root_path

    page.should have_css(".featured-effort:contains('featured effort name')")
  end

  def sees_featured_story
    visit root_path
    page.should have_content "First Story"
    page.should have_content "Some Content"
    page.should have_content "Second Story"
    page.should have_content "More Content"
    page.all(".list-item-image img")[0][:src].should match "white.jpg"
    page.all(".list-item-image img")[1][:src].should match "black.jpg"
  end

end
