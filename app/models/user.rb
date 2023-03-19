# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable, :lockable

  scope :active_users, -> { where(active: true) }
  scope :deact_users, -> { where(active: true) }
  scope :all_users, -> { where(active: [true, false]) }

  # do not allow deactivated users from logging in
  def active_for_authentication?
    super && active == true
  end

end
