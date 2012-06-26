module LoginHelper
  
  def add_to_white_list_and_register(first_name="First", last_name="Last", email="email@test.com",
                                     password="onlyusknowit", phone_number = "1234567", postcode = "2000")
    add_to_whitelist(email)
    register(first_name, last_name, email, password, phone_number, postcode)
  end

  def register(first_name = 'First', last_name = 'Last', email = 'email@test.com', password = 'onlyusknowit', phone_number='1231231234', postcode='2000')
    visit new_user_registration_path
    fill_and_submit_registration_form(first_name, last_name, email, password, phone_number, postcode)
  end

  def add_to_whitelist(email)
    EmailWhiteList.create!(email: email)
  end

  def fill_and_submit_registration_form(first_name, last_name, email, password, phone_number = "1234567",
                                        postcode = "2000", options = {:show_chevrons => false})
    within("form#user_registration") do
      fill_in "user_first_name", with: first_name
      fill_in "user_last_name", with: last_name
      fill_in "user_email", with: email
      fill_in "user_password", with: password
      fill_in "user_phone_number", with: phone_number
      fill_in "user_postcode", with: postcode
      check "user_agree_toc"
    end
    page.should have_css("div.chevron") if options[:show_chevrons]
    click_on "Register"
  end
  
  def log_out
    click_on "Log out"
  end

  def log_in(email="email@test.com", password="onlyusknowit")
    visit root_path
    click_on "Log in"
    
    fill_and_submit_login_form(email, password)
  end
  
  def fill_and_submit_login_form(email, password, options = {:show_chevrons => false})
    within("form#new_user") do
      fill_in "user_email", with: email
      fill_in "user_password", with: password
    end
    page.should have_css("div.chevron") if options[:show_chevrons]
    click_on "Log in"
  end

end
