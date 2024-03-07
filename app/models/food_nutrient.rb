# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class FoodNutrient < ApplicationRecord
  belongs_to :food
  belongs_to :nutrient

  scope :active_food_nutrients, -> { where(active: true) }
  scope :deact_food_nutrients, -> { where(active: false) }
  # scope :all_food_nutrients, -> { where(active: [true, false]) }
  # scope :all_food_nutrients, -> {}

  # automatically convert samples_json (hash) field to JSON string in the database
  serialize :samples_json, coder: JSON  
end
