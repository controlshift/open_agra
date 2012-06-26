Factory.define :location do |c|
  c.query{ Factory.next(:query) }
  c.latitude 30.1
  c.longitude 30.1
  c.postal_code "20003"
  c.region  'IL'
  c.locality 'Chicago'
  c.street '1 main street'

end

Factory.sequence :query do |n|
  "a place called #{n}"
end