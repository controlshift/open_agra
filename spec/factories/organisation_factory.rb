FactoryGirl.define do
  factory :organisation do
    sequence(:name) {|n| Faker::Company.name + n.to_s }
    sequence(:slug) {|n| "slug#{n}"}
    sequence(:host) {|n| "org#{n}.com"}
    contact_email {Faker::Internet.email}
    admin_email {Faker::Internet.email}
    blog_link "http://wwww.wordpress.com"
    notification_url "http://any.url.com"
    sendgrid_username "ausername"
    sendgrid_password "apassword"
    use_white_list false
  end
end

