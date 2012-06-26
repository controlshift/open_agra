# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :effort do
    title {Faker::Lorem.sentence}
    description {Faker::Lorem.paragraph}
    association(:organisation)
  end
end
