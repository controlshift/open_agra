FactoryGirl.define do
  factory :petition do
    title {Faker::Lorem.sentence}
    who {Faker::Name.name}
    what {Faker::Lorem.sentence}
    why {Faker::Lorem.paragraph}
    delivery_details {Faker::Lorem.paragraph}
    admin_status 'unreviewed'
    admin_notes {Faker::Lorem.paragraph}
    cancelled false
    launched true
    campaigner_contactable true
    association(:user)
    association(:organisation)
  end

  factory :cancelled_petition, parent: :petition do
    cancelled true
  end

  factory :invalid_petition, parent: :petition do
    title nil
  end

 factory :inappropriate_petition, parent: :petition do
    admin_status 'inappropriate'
    admin_reason 'It is not appropriate.'
  end
end
