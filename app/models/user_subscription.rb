class UserSubscription < ApplicationRecord
  belongs_to :following, foreign_key: 'following_id', class_name: 'User'
  belongs_to :follower, foreign_key: 'follower_id', class_name: 'User'

  # Validations
  validates :follower_id, presence: true
  validates :following_id, presence: true

  # Validate unique
  validates :follower_id, uniqueness: {scope: :following_id}
end
