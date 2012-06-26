require File.dirname(__FILE__) + '/scenario_helper.rb'

describe "User browses campaigns", type: :request, nip: true, js: true do
  before :each do
    @fred = Factory(:user, organisation: @current_organisation)
    @cat_environment = Factory(:category, name: 'Environment', organisation: @current_organisation)
    @cat_social = Factory(:category, name: 'Social', organisation: @current_organisation)
    @cat_wild_life = Factory(:category, name: 'Wild Life', organisation: @current_organisation)

    search_per_page = 12
    search_per_page.times do |no|
      Factory(:petition, title: "Save #{no}", admin_status: :good, organisation: @current_organisation, user: @fred)
    end

    @pet1 = Factory(:petition, title: 'Save pet 1', admin_status: :awesome, organisation: @current_organisation, user: @fred)
    @pet2 = Factory(:petition, title: 'Save pet 2', admin_status: :good, organisation: @current_organisation, user: @fred)
    @pet3 = Factory(:petition, title: 'pet 3', admin_status: :awesome, organisation: @current_organisation, user: @fred)

    CategorizedPetition.create!(petition: @pet1, category: @cat_environment)
    CategorizedPetition.create!(petition: @pet1, category: @cat_social)
    CategorizedPetition.create!(petition: @pet2, category: @cat_social)
    CategorizedPetition.create!(petition: @pet3, category: @cat_wild_life)

    Sunspot.commit
  end

  it 'visits' do
    browses_more_campaigns
    explores_category
    views_a_campaign
    returns_to_a_catetegory
    searches
  end

  def browses_more_campaigns
    visit root_path
    click_on 'More Campaigns'
    page.should have_content 'Featured'
    page.should have_content @cat_environment.name
    page.should have_content @cat_social.name
    page.should have_content @cat_wild_life.name
  end

  def explores_category
    click_on @cat_social.name
    page.should have_content @pet2.title
    page.should have_content @pet1.title
  end

  def views_a_campaign
    click_on @pet2.title
    page.should have_content @pet2.title
    page.should have_content @cat_social.name
  end

  def returns_to_a_catetegory
    click_on @cat_social.name
    page.current_path.should include(@cat_social.name.downcase)
    page.should have_content @pet2.title
  end

  def searches
    fill_in 'q', with: 'Save'
    click_on 'search-campaign'
    page.current_url.should include 'search?q=Save'
    page.should have_link 'More Campaigns'
    click_on 'More Campaigns'
    page.current_url.should include 'search?page=2&q=Save'
    page.should_not have_content 'More Campaigns'
  end
end
