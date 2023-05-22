# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class UsdaFoodNutrient < ApplicationRecord
  belongs_to :usda_food, :foreign_key => "fdc_id", primary_key: "fdc_id"
  belongs_to :nutrient, :foreign_key => "usda_nutrient_id", primary_key: "usda_nutrient_id"

  scope :active_usda_food_nutrients, -> { where(active: true) }
  scope :deact_usda_food_nutrients, -> { where(active: false) }

end
