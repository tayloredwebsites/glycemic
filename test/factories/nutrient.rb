# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

FactoryBot.define do
  factory :nutrient do
    sequence(:name) { |n| "nutrient #{n}" }
    sequence(:usda_nutrient_id) { |n| n+300 }
    sequence(:usda_nutrient_num) { |n| "#{n}" }
    unit_code {"g"}
  end
end
