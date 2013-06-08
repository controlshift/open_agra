FactoryGirl.define do
  factory :comment do
    text "This is my comment and its really good"
    approved nil
    up_count 0
  end
end
