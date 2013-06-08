FactoryGirl.define do
  factory :geography do
    sequence(:name) {|n|
      "name #{n}"
    }
  end
end
