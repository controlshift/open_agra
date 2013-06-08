# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :target_collection do
    sequence(:name) {|n|
      "name #{n}"
    }
    association(:organisation)
  end
end
