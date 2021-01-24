FactoryBot.define do
  factory :task do
    sequence(:title, 'title_1')
    status { 0 }
    association :user
  end
end
