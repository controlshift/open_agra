require File.dirname(__FILE__) + '/scenario_helper.rb'
include LoginHelper

describe 'Org admin administers categories', type: :request do
  before :each do
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    log_in(@org_admin.email, 'onlyusknowit')
  end

  specify 'create a new category, edit and return to list, delete and return to list' do
    click_on "#{@current_organisation.name} Admin"
    click_on 'all-categories'
    click_on 'New Category'
    fill_in 'Name', with: 'Category name'
    click_on 'Save'

    page.should have_content('Categories')
    page.should have_content('Category name')
    page.should have_content('has been created')
    click_on 'Category name'

    fill_in 'Name', with: 'Another name'
    click_on 'Save'
    
    page.should have_content('Another name')
    page.should have_content('Categories')
    page.should have_content('has been updated')
    
    click_on 'Another name'
    click_on 'Delete'
    
    current_path.should == org_categories_path
    page.should_not have_content('Another name')
  end

end
