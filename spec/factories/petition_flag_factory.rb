FactoryGirl.define do
  factory :petition_flag do
    ip_address {Faker::Internet.ip_v4_address}
    association(:user)
    association(:petition)
  end
end
