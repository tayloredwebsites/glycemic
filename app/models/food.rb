# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class Food < ApplicationRecord
  has_many :food_nutrients, dependent: :destroy

  scope :active_foods, -> { where(active: true) }
  scope :deact_foods, -> { where(active: false) }
  # scope :all_foods, -> { where(active: [true, false]) }
  # scope :all_foods, -> {}

  belongs_to :usda_food_cat,
    class_name: "LookupTable",
    foreign_key: "usda_food_cat_id",
    optional: true
  belongs_to :wweia_food_cat,
    class_name: "LookupTable",
    foreign_key: "wweia_food_cat_id",
    optional: true

  serialize :usda_fdc_ids_json, JSON

  validates :name, presence: true, allow_blank: false

end
