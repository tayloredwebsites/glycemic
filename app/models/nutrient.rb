class Nutrient < ApplicationRecord
  has_many :food_nutrients, dependent: :restrict_with_error

  scope :active_nutrients, -> { where(active: true) }
  scope :deact_nutrients, -> { where(active: false) }
  # scope :all_nutrients, -> { where(active: [true, false]) }
  # scope :all_nutrients, -> {}

end
