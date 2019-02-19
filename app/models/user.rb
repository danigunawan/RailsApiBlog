class User < ApplicationRecord

  # this uses bcrypt so make sure to add it in your Gemfile
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates_length_of :password, :in => 2..80, on: :create

  # Assotiations
  has_many :likes
  has_and_belongs_to_many :roles, :join_table => :users_roles
  has_one :site_subscription
  # Look for article assotiation inside the Like model
  has_many :liked_articles, :through => :likes, :source => :article

  has_many :follower_relationships, foreign_key: :following_id, class_name: 'UserSubscription'
  has_many :followers, through: :follower_relationships, source: :follower

  # Has many followers, retrieved through a foreign_key named 'followed_id' in the FollowRelationShips model
  has_many :following_relationships, foreign_key: :follower_id, class_name: 'UserSubscription'
  has_many :following, through: :following_relationships, source: :following

  after_initialize :init

  # attr_accessor :password

  # Validations

  # has_secure_password
  # validates_confirmation_of :password, if: ->(m) {m.password.present?}
  # validates :password, length: {minimum: 6}

  # scopes
  scope :by_email, ->(email) {where(email: email).first}
  # Model callbacks
  def init
    if roles.empty?
      puts 'empty role'
      role = Role.create_with(description: 'only for authors').find_or_create_by(name: 'ROLE_USER')
      self.roles.append role
      #self.number  ||= 0.0
    end
  end


  # validations
  validates :username, presence: true, allow_blank: false, uniqueness: {case_sensitive: false},
            format: {with: /\A[a-zA-Z0-9]+\z/}

  validates :email, presence: true, allow_blank: false, uniqueness: {case_sensitive: false},
            format: {
                with: URI::MailTo::EMAIL_REGEXP,
                message: 'Please provide a valid email'
            }

  def generate_jwt
    JWT.encode({id: id, user_id: 7, exp: 7.days.from_now.to_i, email: self.email, username: self.username},
               'JWT_SUPER_SECRET')
  end

  def is_standard_user?
    role_user = Role.find_by(name: 'ROLE_USER')
    roles.include?(role_user)
  end

  def is_admin?
    role_admin = Role.find_by(name: 'ROLE_ADMIN')
    roles.include?(role_admin)
  end

  def is_author?
    role_author = Role.find_by(name: 'ROLE_AUTHOR')
    roles.include?(role_author)
  end

  def like(article)
    likes.find_or_create_by(article: article)
  end

  def unlike(article)
    likes.where(article: article).destroy_all
    article.reload
  end

  def is_liking?(article)
    likes.find_by(article: article).present?
  end

  def self.find_by_email(email)
    where(email: email).first
  end

  def self.get_users_not_subscribed
    User.left_joins(:site_subscription).where(site_subscriptions: {id: nil})
  end

  def subscribe_to(user_or_id)
    if user_or_id.is_a? User
      following_relationships.create(following: user_or_id)
    elsif user_or_id.is_a? Numeric
      following_relationships.create(following_id: user_or_id)
    end
  end

  def unsubscribe_from(user_or_id)
    if user_or_id.is_a? User
      following_relationships.find_by(following: user_or_id).destroy
    elsif user_or_id.is_a? Numeric
      following_relationships.find_by(following_id: user_or_id).destroy
    end
  end

  def is_subscribed_to?(user)
    following_relationships.find_by(following_id: user.id)
  end

  def is_subscribed2?(user)
    following.include? user
  end

  def is_standard_user?
    role_user = Role.find_by(name: 'ROLE_USER')
    roles.include?(role_user)
  end

  def get_rand_user_not_subscribed_to
    # find users to follow, useful for seeding or suggestions
    # Search for authors I am not subscribed to them still
    users = User.joins(:roles).where(roles: {name: 'ROLE_AUTHOR'}).where.not(id: following_ids)
    users.offset(rand(users.count)).first
  end

  def get_rand_user_not_subscribed_to_me
    # find users not following me
    users = User.where.not(id: follower_ids)
    users.offset(rand(users.count)).first
  end



  def self.get_random_user_not_liked(article)
    # User.includes(:likes).where.not(likes: {article: article})
    users = User.includes(:likes).where.not(likes: {article_id: article.id})
    users.offset(rand(users.count)).first
    # User.joins(:likes).where.not(likes: {article_id: article.id}).distinct
  end

  def generate_json_api_error
    json_error = {"errors": []}
    errors.messages.each do |err_type, messages|
      messages.each do |msg|
        json_error[:errors] << {"detail": "#{err_type} #{msg}", "source": {"pointer": "user/err_type"}}
      end
    end
    json_error
  end
end
  