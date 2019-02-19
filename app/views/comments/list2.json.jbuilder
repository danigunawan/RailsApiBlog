json.success true
json.comments do |json|
  json.array! @comments, partial: 'comments/comment', as: :comment
end

json.comments_count @comments_count

