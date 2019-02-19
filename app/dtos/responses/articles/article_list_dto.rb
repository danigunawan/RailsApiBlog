class ArticleListDto < BasePagedDto

  attr_accessor :articles

  def initialize(articles, articles_count, base_path, page, page_size)
    super(articles, articles_count, base_path, page, page_size)
    @articles = articles
  end
end