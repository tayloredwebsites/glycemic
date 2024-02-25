# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

FactoryBot.define do
  factory :food do
    sequence(:name) { |n| "Food #{n}" }
    usda_food_cat_id {
      # randomly generate a valid usda cat id from 1 to 28 (or nil if zero)
      num = Faker::Number.between(from: 0, to: 28); (num == 0) ? nil : num
    }
    usda_fdc_ids_json { [ generate(:fdic_id_seq_item) ] }
  end
  # create an item to go in the serialized JSON field usda_fdc_ids_json Array
  sequence(:fdic_id_seq_item, 10000000) { |n| "#{n}"}
end
