json.(article, :id, :title, :description, :created_at, :slug, :updated_at)
# I ignore if this works: json.extract! article, :id, :title, :body, :created_at, :slug, :updated_at
# I ignore if this works: json.url article_url(article, format: :json)
json.tags article.tags, partial: 'tags/basic', as: :tag

# json.comments_count article.comments.count # count, size or length any one works

json.categories do |json|
  json.array! article.categories, partial: 'categories/basic', as: :category
end

# This is the same as above
# json.categories article.categories, partial: 'categories/basic', as: :category
