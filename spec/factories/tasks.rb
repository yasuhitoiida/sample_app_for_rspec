FactoryBot.define do
  factory :task do
    title { "making a cake" }
    status { 0 }
    association :user
  end
end
