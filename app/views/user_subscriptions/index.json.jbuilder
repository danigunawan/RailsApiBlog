json.success true
json.data do |json|
  json.meta @dto.page_meta, partial: 'meta/page_meta', as: :page_meta
  unless @dto.following.nil?
    json.following @dto.following, partial: 'users/id_username', as: :user
  end
  unless @dto.followers.nil?
    json.followers @dto.followers, partial: 'users/id_username', as: :user
  end
end

