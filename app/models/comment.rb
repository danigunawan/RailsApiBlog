class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :article

  has_many :replies, class_name: 'Comment', foreign_key: 'comment_id'
  belongs_to :replied_comment, class_name: 'Comment', foreign_key: 'comment_id', optional: true

  validates :content, presence: true, allow_blank: false, length: {minimum: 2}
end
