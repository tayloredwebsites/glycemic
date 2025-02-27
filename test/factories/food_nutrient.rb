# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

FactoryBot.define do
  factory :food_nutrient do
    association :food, factory: :food
    association :nutrient, factory: :nutrient
    amount {Faker::Number.decimal(r_digits: 1)}
    samples_json {""}

end
# create an fdc id to go in the serialized JSON field samples_json Array
sequence(:fdc_sample_id, 111000) { |n| "fdc,#{n}"}

end
