FactoryGirl.define do
  factory :group_member do
    invitation_email { Faker::Internet.email }
    user
    group
  end

end
