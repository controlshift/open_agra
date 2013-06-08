module PetitionHelper
  
  def create_petition(title = 'This is my petition', 
                      who = 'Fred Daman, CEO of Fredcorp', 
                      what = 'Tell Fred to pay everyone more money', 
                      why = 'I want more money', &block)
    visit new_petition_path
    fill_in_petition(title, who, what, why)
    yield if block_given?
    click_on 'Save'
  end

  def create_and_launch_petition(title = 'This is my petition', 
                      who = 'Fred Daman, CEO of Fredcorp', 
                      what = 'Tell Fred to pay everyone more money', 
                      why = 'I want more money', &block)
    create_petition(title, who, what, why, &block)
    click_on 'launch-petition'
  end

  def fill_in_petition(title = 'This is my petition',
                      who = 'Fred Daman, CEO of Fredcorp',
                      what = 'Tell Fred to pay everyone more money',
                      why = 'I want more money')
    fill_in 'petition_title', with: title
    fill_in 'petition_who', with: who
    fill_in 'petition_what', with: what
    fill_in 'petition_why', with: why

  end
  
  def create_petition_with_image(title, image_file_name)
    create_petition(title) do
      attach_file :image, Rails.root.join("scenarios/fixtures/white.jpg")
    end
  end

  def sign_petition(petition_slug = 'this-is-my-petition',
                    first_name = 'Sean',
                    last_name = 'Ho',
                    email = 'sean.ho@thoughtworks.com',
                    phone = '0418773733',
                    postcode = '2000')
    visit petition_path(petition_slug)
    fill_in 'signature_first_name',  with: first_name
    fill_in 'signature_last_name', with: last_name
    fill_in 'signature_email', with: email
    fill_in 'signature_phone_number', with:phone
    fill_in 'signature_postcode', with:postcode

    click_on 'Sign'
  end

  def leave_a_comment(comment = "This is a test comment")
    fill_in 'comment_text', with: comment

    click_on 'Save'
  end

  def edit_petition(petition_slug, title = 'This is my petition',
      who = 'Fred Daman, CEO of Fredcorp',
      what = 'Tell Fred to pay everyone more money',
      why = 'I want more money',
      delivery_details = "Sydney", categories = [])
    fill_in 'petition_title', with: title
    fill_in 'petition_who', with: who
    fill_in 'petition_what', with: what
    fill_in 'petition_why', with: why
    fill_in 'petition_delivery_details', with: delivery_details
    attach_file :image, Rails.root.join("scenarios/fixtures/white.jpg")
    categories.each do |category|
      check category
    end
  end
end
