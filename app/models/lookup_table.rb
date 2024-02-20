# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class LookupTable < ApplicationRecord

  VALID_UNIT_CODES = {
    "G" => "Gram(s)",
    "kG" => "Kilogram(s)",
    "mG" => "Miligram(s)",
    "MG" => "Miligram(s)",
    "uG" => "Microgram(s)",
    "UG" => "Microgram(s)",
    "LB" => "Pound(s)",
    "OZ" => "Ounce(s)",
    "FL_OZ" => "Fluid Ounce(s)",
    "L" => "Liter(s)",
    "mL" => "Mililiter(s)",
    "uL" => "Microliter(s)",
    "CM^3" => "Cubic Centieters(s)",
    "MM^3" => "Cubic Milimeters(s)",
    "OZ" => "Ounce(s)",
    "IU" => "International Units",
    "KCAL" => "Kilocalorie(s)",
    "kJ" => "Kilojoules",
    "MCG_RE" => "Microgram(s) (??)",
    "MG_ATE" => "Miligram(s) (??)",
    "MG_GAE" => "Miligram(s) (??)",
    "PH" => "Potential of Hydrogen (acid/alkaline)",
    "SP_GR" => "Specific Gravity",
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
