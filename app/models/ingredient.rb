# Diet Support Program
# Copyright (C) 2024 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class Ingredient < ApplicationRecord
  belongs_to :parent_food,
    class_name: "Food",
    foreign_key: :parent_food_id
  belongs_to :food
  belongs_to :lu_unit_code,
    class_name: "LookupTable",
    foreign_key: :lu_unit_code

  scope :active_ingredients, -> { where(active: true) }
  scope :deact_ingredients, -> { where(active: false) }

end
