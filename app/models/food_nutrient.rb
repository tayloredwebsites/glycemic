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

end
