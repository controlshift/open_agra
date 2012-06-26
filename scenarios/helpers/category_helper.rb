module CategoryHelper
  def add_new_category(name)
    visit new_org_category_path
    fill_in 'Name', with: name
    click_on 'Save'
  end
end