FactoryGirl.define do
  factory :petition_blast_email do
    from_name {Faker::Name.name}
    from_address {Faker::Internet.email}
    subject {Faker::Lorem.sentence}
    body {Faker::Lorem.paragraph}
    association(:petition)

    factory :inappropriate_petition_blast_email do
      moderation_status 'inappropriate'
      moderation_reason 'change your email content please'
    end
  end
end
