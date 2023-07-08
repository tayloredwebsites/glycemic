# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class FoodNutrient < ApplicationRecord
  belongs_to :food
  belongs_to :nutrient

  GRAM = 'g'.freeze
  MILI_GRAM = 'mg'.freeze
  MICRO_GRAM = 'ug'.freeze
  OUNCE = 'oz'.freeze
  CUP = 'c'.freeze
  FLUID_OUNCE = 'fl oz'.freeze
  TABLESPOON = 'tbsp'.freeze
  TEASPOON = 'tsp'.freeze
  PINCH = 'pinch'.freeze
  LITER = 'l'.freeze

  MEASUREMENTS = [
    GRAM,
    MILI_GRAM,
    MICRO_GRAM,
    OUNCE,
    CUP,
    FLUID_OUNCE,
    TABLESPOON,
    TEASPOON,
    PINCH,
    LITER,
  ].freeze

  scope :active_food_nutrients, -> { where(active: true) }
  scope :deact_food_nutrients, -> { where(active: false) }
  # scope :all_food_nutrients, -> { where(active: [true, false]) }
  # scope :all_food_nutrients, -> {}

  # automatically convert samples_json (hash) field to JSON string in the database
  serialize :samples_json, JSON
  
end
