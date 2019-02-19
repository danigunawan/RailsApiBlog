class Category < ApplicationRecord
  has_and_belongs_to_many :articles, :join_table => :articles_categories
  scope :users_posted_on_this, ->(username) {where(article: Article.where(user: User.where(username: username)))}
  validates :name, presence: true, uniqueness: true
end
