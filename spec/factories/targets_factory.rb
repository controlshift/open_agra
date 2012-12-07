# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :target do
    name {Faker::Name.name}
    phone_number "123456"
    email "123@abc.com"
    association(:location)
    association(:organisation)
  end
end
