json.success true
json.authenticated @authenticated
json.data do |json|
  json.meta @page_meta, partial: 'meta/page_meta', as: :page_meta
  json.articles do |json|
    json.array! @articles, partial: 'articles/article', as: :article
  end
end


json.articles_count @articles_count
json.articles_count @articles.count
