# == Schema Information
#
# Table name: members
#
#  id              :integer         not null, primary key
#  email           :string(255)
#  organisation_id :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member do
    sequence(:email) {|n|
      parts = Faker::Internet.email.split("@")
      "#{parts[0]}#{n}@#{parts[1]}"
    }
  end
end
