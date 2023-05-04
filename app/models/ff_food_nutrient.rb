# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class FfFoodNutrient < ApplicationRecord
  belongs_to :ff_food
  belongs_to :nutrient

  scope :active_ff_food_nutrients, -> { where(active: true) }
  scope :deact_ff_food_nutrients, -> { where(active: false) }

end
