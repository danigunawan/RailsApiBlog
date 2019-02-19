class ArticleCreateEditDto < BaseRequestDto

  def initialize(params)
    super(params)
    @sanitized_params = {}
    title = params[:title]
    description = params[:description]
    body = params[:body]
    tags = params[:tags]
    categories = params[:categories]

    if title
      @sanitized_params.merge!(:title => title)
    end

    if description
      @sanitized_params.merge!(:description => description)
    end

    if body
      @sanitized_params.merge!(:body => body)
    end

    if tags
      @sanitized_params.merge!(:tags => tags)
    end

    if categories
      @sanitized_params.merge!(:categories => categories)
    end
  end

  def has_tags?
    @sanitized_params.has_key?(:tags)
  end

  def get_tags
    @sanitized_params[:tags]
  end

  def has_categories?
    @sanitized_params.has_key?(:categories)
  end

  def get_categories
    @sanitized_params[:categories]
  end

  def get_params
    @sanitized_params.except(:tags, :categories)
  end
end