FactoryGirl.define do
  factory :category do
    sequence(:name) {|n| "category#{n}"}
    external_id nil
    association(:organisation)

    factory :invalid_category do
      name ''
    end
  end
end
