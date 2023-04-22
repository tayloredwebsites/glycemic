# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class UsdaFoodNutrient < ApplicationRecord
  belongs_to :usda_food
  belongs_to :usda_nutrient

  scope :active_usda_food_nutrients, -> { where(active: true) }
  scope :deact_usda_food_nutrients, -> { where(active: false) }

end
