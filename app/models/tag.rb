class Tag < ApplicationRecord
  has_and_belongs_to_many :articles, :join_table => :articles_tags

  validates :name, presence: true, uniqueness: {case_sensitive: false},
            length: {maximum: 150}
end
