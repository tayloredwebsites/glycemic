# Diet Support Program
# Copyright (C) 2024 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class Alternate < ApplicationRecord
  belongs_to :parent_food,
    class_name: "Food",
    foreign_key: "parent_food_id"
  belongs_to :food

  scope :active_alternates, -> { where(active: true) }
  scope :deact_alternates, -> { where(active: false) }

end
