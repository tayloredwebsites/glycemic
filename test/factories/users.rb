FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}_email@sample.org"}
    sequence(:full_name) { |n| "user_full_name#{n}"}
    password { "password"}
    password_confirmation { "password"}
  end
end
