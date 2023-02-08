class Food < ApplicationRecord
  has_many :food_nutrients, dependent: :destroy
end
