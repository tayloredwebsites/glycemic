# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

FactoryBot.define do

  trait :user_common_attrs do
    sequence(:email) { |n| "user#{n}_email@sample.org"}
    sequence(:full_name) { |n| "user_full_name#{n}"}
    password { "password"}
    password_confirmation { "password"}
  end

  factory :user do
    user_common_attrs
    confirmed_at {DateTime.now()}
  end

  factory :unconfirmed_user, class: :user do
    user_common_attrs
  end

end
