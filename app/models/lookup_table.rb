# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class LookupTable < ApplicationRecord

  VALID_UNIT_CODES = {
    "G" => "Gram(s)",
    "IU" => "International Units",
    "KCAL" => "Kilocalorie(s)",
    "kJ" => "Kilojoules",
    "MCG_RE" => "Microgram(s) (??)",
    "MG" => "Miligram(s)",
    "MG_ATE" => "Miligram(s) (??)",
    "MG_GAE" => "Miligram(s) (??)",
    "PH" => "Potential of Hydrogen (acid/alkaline)",
    "SP_GR" => "Specific Gravity",
    "UG" => "Microgram(s)",
    "UMOL_TE" => "Micromole (??)",
  }
  
  has_many :usda_food_cat,
    class_name: "Food"

  has_many :wweia_food_cat,
    class_name: "Food"

  scope :active_lookups, -> { where(active: true) }
  scope :deact_lookups, -> { where(active: false) }

  validates :lu_table, presence: true
  validates :lu_code, presence: true

end
