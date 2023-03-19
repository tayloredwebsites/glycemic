# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class Food < ApplicationRecord
  has_many :food_nutrients, dependent: :destroy

  scope :active_foods, -> { where(active: true) }
  scope :deact_foods, -> { where(active: false) }
  # scope :all_foods, -> { where(active: [true, false]) }
  # scope :all_foods, -> {}

  # belongs_to :usda_food_cat_lu, class_name: :lookup_tables
  # belongs_to :wweia_food_cat_lu, class_name: :lookup_tables

end
