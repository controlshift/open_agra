FactoryGirl.define do
  factory :geographic_collection do
    sequence(:name) {|n|
      "name #{n}"
    }
  end
end