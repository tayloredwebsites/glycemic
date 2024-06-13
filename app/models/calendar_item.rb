# Diet Support Program
# Copyright (C) 2024 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class CalendarItem < ApplicationRecord
  belongs_to :user
  belongs_to :lu_event_type,
    class_name: "LookupTable",
    foreign_key: :lu_event_type
  belongs_to :food, optional: true
  belongs_to :lu_unit_code,
    class_name: "LookupTable",
    foreign_key: :lu_unit_code,
    optional: true
  
  scope :active_goals, -> { where(active: true) }
  scope :deact_goals, -> { where(active: false) }

end
