FactoryBot.define do
  factory :user do
    email { "example@runteq.org" }
    password { "password" }
    password_confirmation { "password" }
  end
end
