json.success true
json.data do |json|
  json.meta @dto.page_meta, partial: 'meta/page_meta', as: :page_meta
  json.articles do |json|
    json.array! @dto.articles, partial: 'articles/article_summary', as: :article
  end
end

json.articles_count @dto.articles.count
