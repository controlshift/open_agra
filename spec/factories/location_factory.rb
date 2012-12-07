FactoryGirl.define  do

  factory :location do |c|
    c.query { Factory.next(:query) }
    c.latitude 30.1
    c.longitude 30.1
    c.postal_code "20003"
    c.region 'IL'
    c.locality 'Chicago'
    c.street '1 main street'

  end

  factory :museum, parent: :location do
    locality 'Museum'
    latitude -33.876473
    longitude 151.209683
  end

  factory :manly, parent: :location do
    locality 'Manly'
    latitude -33.797944
    longitude 151.285686
  end
end

Factory.sequence :query do |n|
  "a place called #{n}"
end