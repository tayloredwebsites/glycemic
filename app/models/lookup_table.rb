# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class LookupTable < ApplicationRecord
  # has_many :food_usda_food_cat, class_name: :food, foreign_key: :usda_food_cat_lu_id
  # has_many :food_wweai_food_cat, class_name: :food, foreign_key: :wweia_food_cat_lu_id
  has_many :usda_cat, class_name: :food, foreign_key: :usda_food_cat_lu_id
  has_many :wweia_cat, class_name: :food, foreign_key: :wweia_food_cat_lu_id

  scope :active_lookups, -> { where(active: true) }
  scope :deact_lookups, -> { where(active: false) }

  validates_presence_of :lu_table
  validates_presence_of :lu_code

end
