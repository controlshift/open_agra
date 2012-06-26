FactoryGirl.define do
  factory :story do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.sentence }
    featured false
    link "http://www.communityrun.org"
    image_file_name 'image.jpg'
    image_content_type 'image/jpg'
    image_file_size 1024
    image_updated_at Time.now
  end
end
