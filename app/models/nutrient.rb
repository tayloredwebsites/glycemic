class Nutrient < ApplicationRecord
  has_many :food_nutrients, dependent: :restrict_with_error
end
