class FoodNutrient < ApplicationRecord
  belongs_to :food
  belongs_to :nutrient

  GRAM = 'g'
  MILI_GRAM = 'mg'
  MICRO_GRAM = 'ug'
  OUNCE = 'oz'
  CUP = 'c'
  FLUID_OUNCE = 'fl oz'
  TABLESPOON = 'tbsp'
  TEASPOON = 'tsp'
  PINCH = 'pinch'
  LITER = 'l'

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
  ]

  scope :active_food_nutrients, -> { where(active: true) }
  scope :deact_food_nutrients, -> { where(active: false) }
  # scope :all_food_nutrients, -> { where(active: [true, false]) }
  # scope :all_food_nutrients, -> {}
end
