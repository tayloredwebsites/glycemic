# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class UsdaFood < ApplicationRecord
  has_many :usda_food_nutrients, dependent: :destroy

  scope :active_usda_foods, -> { where(active: true) }
  scope :deact_usda_foods, -> { where(active: false) }

end
