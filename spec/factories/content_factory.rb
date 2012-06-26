FactoryGirl.define do
  factory :content do
    name {Faker::Lorem.sentence}
    body {Faker::Lorem.paragraph}
    sequence(:slug) {|n| "content-#{n}"}
    category { 'Footer' }
    association(:organisation)
  end
end
