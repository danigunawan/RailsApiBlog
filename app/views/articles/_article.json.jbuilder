json.(article, :id, :title, :created_at, :slug, :updated_at)
json.tags article.tags, partial: 'tags/basic', as: :tag
json.categories do |json|
  json.array! article.categories, partial: 'categories/basic', as: :category
end

# This is the same as above
# json.categories article.categories, partial: 'categories/basic', as: :category

json.comments article.comments, partial: 'comments/comment', as: :comment
# json.comments_count article.comments.count # count, size or length any one works
