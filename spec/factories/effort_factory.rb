# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :effort do
    title {Faker::Lorem.sentence}
    description {Faker::Lorem.paragraph}
    effort_type {'open_ended'}
    association(:organisation)
  end

  factory :specific_targets_effort, parent: :effort do
    effort_type {"specific_targets"}
    title_default {"specific targets effort title"}
    what_default {"specific targets effort what"}
    why_default {"specific targets effort why"}
    leader_duties_text {"leader duty"}
    how_this_works_text {"how this works"}
    training_text {"training text"}
    training_sidebar_text {"training sidebar text"}
  end
end
