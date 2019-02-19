# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'

if false
  namespace :db do
    desc "Truncate all tables"
    # task :truncate => :environment do
    conn = ActiveRecord::Base.connection
    tables = conn.execute("show tables").map {|r| r[0]}
    # tables.delete "schema_migrations"
    tables.each {|t| conn.execute("TRUNCATE #{t}")}
    # end
  end
end

def seed_admin
  # find_by then if does not exist create it, later I use a better approach with create_with
  puts "[+] Seeding roles"
  admin_role = Role.find_by(name: 'ROLE_ADMIN')
  unless admin_role
    admin_role = Role.create(name: 'ROLE_ADMIN', description: 'only for admins')
  end
  admin = User.find_by(username: 'admin')
  puts "[+] Seeding Admin"
  unless admin
    admin = User.new(
        username: 'admin',
        first_name: 'adminFN',
        last_name: 'adminLN',
        email: 'admin@melardev.com',
        roles: [admin_role],
    )
    admin.password = 'password'
    admin.password_confirmation = 'password' # this is needed when using has_secure_password as we are in this app
    admin.save!
  end

end

def seed_authors
  author_role = Role.find_by(name: 'ROLE_AUTHOR')
  unless author_role
    author_role = Role.create(name: 'ROLE_AUTHOR', description: 'only for authors')
  end
  authors_count = User.includes(:roles).where(roles: {name: 'ROLE_AUTHOR'}).count
  authors_to_seed = 5
  puts "[+] Seeding #{authors_to_seed - authors_count} authors"
  (authors_to_seed - authors_count).times do |index|
    user = User.create!(
        first_name: Faker::Name::first_name,
        last_name: Faker::Name::last_name,
        username: Faker::Name.first_name,
        email: Faker::Internet.email,
        password: 'password',
        password_confirmation: 'password', # this is needed when using has_secure_password as we are in this app
        roles: [author_role],
    )
  end
end

def seed_users

  user_role = Role.find_by(name: 'ROLE_USER')
  unless user_role
    user_role = Role.create(name: 'ROLE_USER', description: 'only for authenticated users')
  end

  users_count = User.includes(:roles).where(roles: {name: 'ROLE_USER'}).count
  users_to_seed = 35
  if users_to_seed - users_count > 0
    puts "[+] Seeding #{users_to_seed - users_count} users"
    (users_to_seed - users_count).times do |index|
      user = User.create(
          username: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.email,
          password: 'password',
          password_confirmation: 'password', # this is needed when using has_secure_password as we are in this app
          roles: [user_role]
      )
    end
  else
    puts "Already #{users_to_seed} users in database, not seeding"
  end
end

def seed_tags
  # Tags
  puts '[+] Seeding Tags'
  untagged = Tag.create_with(description: 'Not tagged articles').find_or_create_by(name: 'untagged')
  spring_tag = Tag.create_with(description: 'Articles covering the Spring framework: MVC, Boot, Security, Roo, etc.').find_or_create_by(name: 'spring')
  rails_tag = Tag.create_with(description: 'Articles explaining rails in depth').find_or_create_by(name: 'rails')
  laravel_tag = Tag.create_with(description: 'Articles explaining Laravel web development in depth').find_or_create_by(name: 'laravel')
  dotnet_tag = Tag.create_with(description: 'Articles explaining Asp.Net Core in depth').find_or_create_by(name: '.net core mvc')
end

def seed_categories
# Categories
  puts '[+] Seeding Categories'
  uncategorised = Category.create_with(description: 'uncategorised articles').find_or_create_by(name: 'uncategorised')
  java_category = Category.create_with(description: 'Articles covering the Java SE and Java EE').find_or_create_by(name: 'java')
  ruby_category = Category.create_with(description: 'Articles providing some snippets one ruby scripting').find_or_create_by(name: 'ruby')
  cpp_category = Category.create_with(description: 'The awesome word of cpp with Boost, WxWidgets, Qt and raw Win32').find_or_create_by(name: 'cpp')
  php_category = Category.create_with(description: 'Let\'s learn not to make spaguetti code with php anymore').find_or_create_by(name: 'php')
end

def seed_articles

  articles_count = Article.count
  articles_to_seed = 55

  if articles_to_seed - articles_count > 0
    authors = User.includes(:roles).where(:roles => {name: 'ROLE_AUTHOR'})
    puts "Retrieved #{authors.count} authors"
    # or
    # authors = User.joins(:roles).where(:roles => {name: 'ROLE_AUTHOR'})
    # read a good explanation on http://tomdallimore.com/blog/includes-vs-joins-in-rails-when-and-where/
    puts "[+] Seeding #{articles_to_seed - articles_count} Articles"
    (articles_to_seed - articles_count).times do |index|
      puts "seeding article #{index}"
      tags_to_add = [0, rand(Tag.count)].min
      tags_to_add = [tags_to_add, 3].max # no more than 3 tags
      tags = Set[]
      tags_to_add.times do |i|
        tags.add Tag.offset(rand(Tag.count)).first
      end

      categories_to_add = [0, rand(Category.count)].min
      categories_to_add = [categories_to_add, 3].max # no more than 3 categories
      categories = Set[]
      categories_to_add.times do |i|
        categories.add Category.offset(rand(Category.count)).first
      end

      a = Article.new(
          title: Faker::Lorem.sentence,
          description: Faker::Lorem.sentences(2),
          body: Faker::Lorem.paragraph(3),
          user: authors.offset(rand(authors.count)).first,
          tags: tags.to_a, # to array
          categories: categories.to_a,
          views: Faker::Number.between(0, 20000)
      )
      a.save!
    end
  end
end

def seed_comments
  comments_count = Comment.count
  comments_to_seed = 41

  if comments_to_seed - comments_count
    puts "[+] Seeding #{comments_to_seed - comments_count} Comments"
    (comments_to_seed - comments_count).times do |i|
      Comment.create!(
          content: Faker::Lorem.sentence,
          article: Article.offset(rand(Article.count)).first,
          user: User.offset(rand(User.count)).first
      )
    end
  end
end

def seed_replies
  replies_count = Comment.where.not(replied_comment: nil).count
  replies_to_seed = 22

  if replies_to_seed - replies_count
    puts "[+] Seeding #{replies_to_seed - replies_count} Comments"
    (replies_to_seed - replies_count).times do |i|
      replied_comment = Comment.offset(rand(Comment.count)).first
      Comment.create!(
          content: Faker::Lorem.sentence,
          article: replied_comment.article,
          replied_comment: replied_comment,
          user: User.offset(rand(User.count)).first
      )
    end
  end
end

def seed_likes
  likes_count = Like.count
  likes_to_seed = 50

  if likes_to_seed - likes_count
    puts "[+] Seeding #{likes_to_seed - likes_count} Likes"
    user_ids = User.all.pluck 'id'
    (likes_to_seed - likes_count).times do |i|
      article = Article.offset(rand(Article.count)).first
      # User.includes(:likes).where.not(likes: {article: article})
      # User.joins(:likes).where.not(likes: {article_id: article.id}).distinct
      # users = User.includes(:likes).where.not(likes: {article_id: article.id})
      users_liked = User.select('id').includes(:likes).where(likes: {article_id: article.id}).pluck 'id'
      users_not_liking_yet = user_ids.reject {|x| users_liked.include? x}
      user = users_not_liking_yet.sample

      Like.create!(
          article: article,
          user_id: user
      )
    end
  end
end

def seed_user_subscriptions
  site_subscriptions_count = UserSubscription.count
  if site_subscriptions_count <= 0
    puts '[+] Seeding users subscriptions'
    users = User.all
    users.each do |follower|
      relationships_to_seed = rand(2)

      relationships_to_seed.times do |i|
        following = follower.get_rand_user_not_subscribed_to
        follower.subscribe_to following
      end
    end
  end
end

def seed_site_subscriptions
  site_subscriptions_count = SiteSubscription.count
  site_subscriptions_to_seed = 10

  if site_subscriptions_to_seed - site_subscriptions_count
    puts "[+] Seeding #{site_subscriptions_to_seed - site_subscriptions_count} Site subscriptions"
    (site_subscriptions_to_seed - site_subscriptions_count).times do |i|
      users = User.get_users_not_subscribed
      user = users.offset(rand(users.count)).first
      SiteSubscription.create!(
          user: user
      )
    end
  end
end

def seed
  seed_admin
  seed_authors
  seed_users
  seed_tags
  seed_categories
  seed_articles
  seed_comments
  seed_replies
  seed_likes
  seed_site_subscriptions
  seed_user_subscriptions
end

seed