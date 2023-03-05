class Food < ApplicationRecord
  has_many :food_nutrients, dependent: :destroy

  scope :active_foods, -> { where(active: true) }
  scope :deact_foods, -> { where(active: false) }
  # scope :all_foods, -> { where(active: [true, false]) }
  # scope :all_foods, -> {}

end
