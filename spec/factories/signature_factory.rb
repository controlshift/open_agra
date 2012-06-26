FactoryGirl.define do
  factory :signature do
    sequence(:email) {|n| 
      parts = Faker::Internet.email.split("@")
      "#{parts[0]}#{n}@#{parts[1]}"
    }
    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    postcode {Faker::Address.postcode}
    sequence(:phone_number) {|n| "12345-#{n}"}
  end
  
  factory :blank_signature, :parent => :signature do
    first_name ""
    last_name ""
    email ""
    phone_number ""
    postcode ""
  end
end
