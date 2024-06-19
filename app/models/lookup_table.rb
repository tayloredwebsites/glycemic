# Diet Support Program
# Copyright (C) 2024 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class LookupTable < ApplicationRecord

  VALID_UNIT_CODES = {
    "G" => "Gram(s)",
    "kG" => "Kilogram(s)",
    "mG" => "Miligram(s)",
    "uG" => "Microgram(s)",
    "LB" => "Pound(s)",
    "OZ" => "Ounce(s)",
    "FL_OZ" => "Fluid Ounce(s)",
    "C" => "Cup(s)",
    "TBSP" => "Tablespoon(s)",
    "TSP" => "Teaspoon(s)",
    "PINCH" => "Pinch",
    "L" => "Liter(s)",
    "mL" => "Mililiter(s)",
    "uL" => "Microliter(s)",
    "IU" => "International Units",
    "kCAL" => "Kilocalorie(s)",
    "kJ" => "Kilojoules",
    "mG_RE" => "Miligram(s) Retinol",
    "mG_ATE" => "Miligram(s) Alpha Tocopherol Equivalents ",
    "mG_GAE" => "Miligram(s) Gallic Acid",
    "uG_RE" => "Microgram(s) Retinol",
    "uG_ATE" => "Microgram(s) Alpha Tocopherol Equivalents ",
    "uG_GAE" => "Microgram(s) Gallic Acid",
    "PH" => "Potential of Hydrogen (acid/alkaline)",
    "SP_GR" => "Specific Gravity",
    "uMOL_TE" => "Micromole Trolox Equivalents",
  }.freeze
  
  DEPRECATED_UNIT_CODES = {
    "MG" => "mG",
    "UG" => "uG",
    "KCAL" => "kCAL",
    "MCG_RE" => "uG_RE",
    "MG_ATE" => "mG_ATE",
    "MG_GAE" => "mG_GAE",
    "UMOL_TE" => "uMOL_TE",
  }.freeze
  


  has_many :usda_food_cat,
    class_name: "Food"

  has_many :wweia_food_cat,
    class_name: "Food"

  scope :active_lookups, -> { where(active: true) }
  scope :deact_lookups, -> { where(active: false) }

  validates :lu_table, presence: true
  validates :lu_code, presence: true

end
