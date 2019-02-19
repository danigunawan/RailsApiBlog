json.success true
json.likes do |json|
    json.array! @likes, partial: 'likes/like', as: :like
end

json.likes_count @likes_count
