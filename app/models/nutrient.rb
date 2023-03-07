# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class Nutrient < ApplicationRecord
  has_many :food_nutrients, dependent: :restrict_with_error

  scope :active_nutrients, -> { where(active: true) }
  scope :deact_nutrients, -> { where(active: false) }
  # scope :all_nutrients, -> { where(active: [true, false]) }
  # scope :all_nutrients, -> {}

end
