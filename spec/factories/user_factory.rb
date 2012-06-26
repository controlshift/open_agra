FactoryGirl.define do
  factory :user do
    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    sequence(:email) {|n|
      parts = Faker::Internet.email.split("@")
      "#{parts[0]}#{n}@#{parts[1]}"
    }
    postcode {Faker::Address.postcode}
    password "onlyusknowit"
    sequence(:phone_number) {|n| "12345-#{n}"}
    agree_toc "1"
    association(:organisation)

    factory :admin do
      admin true
    end

    factory :org_admin do
      org_admin true
    end
  end
end
