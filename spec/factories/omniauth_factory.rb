# Information about the hash taken at https://github.com/mkdynamic/omniauth-facebook
require 'ostruct'
FactoryGirl.define do
  sequence :facebook_access_token do
    OpenStruct.new(
      provider: :facebook,
      uid: '1234',
      info: OpenStruct.new(email: Faker::Internet.email,
                           first_name: Faker::Name.first_name,
                           last_name: Faker::Name.last_name),
      credentials: OpenStruct.new(token: "token")
    )
  end

  sequence :invalid_facebook__access_token do
    OpenStruct.new(
      provider: :facebook,
      invalid: :invalid_credentials
    )
  end

end
