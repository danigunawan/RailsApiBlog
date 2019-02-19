json.success true
json.data do |json|
  json.meta @dto.page_meta, partial: 'meta/page_meta', as: :page_meta
  json.comments do |json|
    json.array! @dto.comments, partial: 'comments/comment', as: :comment
  end
end