class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable

  scope :active_users, -> { where(active: true) }
  scope :deact_users, -> { where(active: true) }
  scope :all_users, -> { where(active: [true, false]) }

end
