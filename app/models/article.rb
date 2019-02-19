class Article < ApplicationRecord
  # Relationships
  belongs_to :user
  has_many :comments, dependent: :destroy


  has_many :likes, dependent: :destroy #, as: :likable
  # Look for user assotiation inside the Like model
  has_many :users_liked, :through => :likes, :source => :user


  scope :liked_by, -> (username) {joins(:likes).where(likes: {user: User.where(username: username)})}

  has_and_belongs_to_many :tags, :join_table => :articles_tags
  has_and_belongs_to_many :categories, :join_table => :articles_categories

  # A user can like once, so uniquenes for two columns: user_id and article_id


  # Articles written by a user given a username
  scope :from_user, ->(username) {where(user: User.where(username: username))}

  # Articles tagged with a given tag name
  scope :tagged_with, ->(tag) {joins(:tags).where(tags: {name: tag})}

  # Articles categories with give ncategory name
  # Article.includes(:categories).where(:categories=>{name: 'sports'})
  scope :categorised_as, ->(name) {joins(:categories).where(:categories => {name: name})}

  # Validations
  validates :title, presence: true, allow_blank: false, length: {minimum: 1, maximum: 500}
  validates :body, presence: true, allow_blank: false, length: {minimum: 1}
  validates :slug, uniqueness: true

  # before_save will be too late, because it would faile the validation, so after_initialize is a good one
  # https://stackoverflow.com/questions/6249475/ruby-on-rails-callback-what-is-difference-between-before-save-and-before-crea
  before_validation do
    # self.slug ||= "#{title.to_s.parameterize}"
    self.slug = "#{title.to_s.parameterize}"
  end

  before_save :init

  # attr_accessor :password

  def init
    if tags.empty?
      puts 'empty tags'
      tag = Tag.create_with(description: 'untagged articles').find_or_create_by(name: 'untagged')
      self.tags.append tag
    end

    if categories.empty?
      category = Category.create_with(description: 'uncategorised articles').find_or_create_by(name: 'uncategorised')
      self.categories.append category
    end
  end

end
