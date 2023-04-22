# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class FoodPortionGram < ApplicationRecord
  belongs_to :food

  scope :active_food_portions, -> { where(active: true) }
  scope :deact_food_portions, -> { where(active: false) }

end
