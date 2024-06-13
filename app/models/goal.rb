# Diet Support Program
# Copyright (C) 2024 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class Goal < ApplicationRecord
  belongs_to :user
  belongs_to :nutrient, optional: true
  belongs_to :food, optional: true
  belongs_to :usda_food_cat,
    class_name: "LookupTable",
    foreign_key: :usda_food_cat_id,
    optional: true
  belongs_to :lu_unit_code,
    class_name: "LookupTable",
    foreign_key: :lu_unit_code

  scope :active_goals, -> { where(active: true) }
  scope :deact_goals, -> { where(active: false) }

end
