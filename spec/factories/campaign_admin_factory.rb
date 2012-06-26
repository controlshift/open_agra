FactoryGirl.define do
  factory :campaign_admin do
    invitation_email { Faker::Internet.email }
    user
    petition
  end

end
