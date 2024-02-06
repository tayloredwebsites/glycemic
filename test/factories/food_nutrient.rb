# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

FactoryBot.define do
  factory :food_nutrient do
    association :food, factory: :food
    association :nutrient, factory: :nutrient
    amount {Faker::Number.decimal(r_digits: 1)}
    # cannot post a FoodNutrient with json as field value
    # TODO: must have post action add and remove samples from FoodNutrient
    # samples_json { { "#{generate(:fdc_sample_id)}": {
    #   "amount": "#{Faker::Number.decimal(r_digits: 1)}",
    #   "data_points": "1",
    #   "weight": "1.0",
    #   "active": true,
    #   "notes": "",
    #   "time_entered": "#{Time.now.to_s}"
    # } } }
    samples_json {""}

end
# create an fdc id to go in the serialized JSON field samples_json Array
sequence(:fdc_sample_id, 111000) { |n| "fdc,#{n}"}

end
