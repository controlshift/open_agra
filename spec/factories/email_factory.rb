FactoryGirl.define do
  factory :email do
    to_address {Faker::Internet.email}
    from_name {Faker::Name.name}
    from_address {Faker::Internet.email}
    subject {Faker::Lorem.sentence}
    content {Faker::Lorem.paragraph}
  end
end