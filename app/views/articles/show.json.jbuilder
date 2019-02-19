json.success true

json.partial! 'articles/article', article: @article
json.body @article.body

=begin
json.article do |json|
    json.partial! 'articles/article', article: @article
end
=end
