FactoryGirl.define do
  factory :group do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }

    association(:organisation)
  end
end
