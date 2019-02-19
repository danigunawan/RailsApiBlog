# rails generate scaffold Article title:strin content:string
# rails generate migration add_user_to_article
# rake db:migrate

class ArticlesController < ApplicationController
  # set @article instance variable for show, update, destroy
  before_action :set_article, only: [:show, :update, :destroy, :likes, :article_by_id]
  # Require authentication for write operations(create, update, destroy)
  before_action :authenticate_user, only: [:create, :update, :destroy]
  before_action :has_author_or_admin_role, only: [:create, :update, :destroy]
  before_action :ensure_ownership, only: [:update, :destroy]

  # GET /articles
  def index
    # @articles = Article.all
    articles = Article.all.includes(:user)
    articles_count = articles.count
    page_size = 10
    if params[:page].blank?
      page = 1
    else
      page = params[:page].to_i
    end
    articles = articles.order(created_at: :desc).offset((page - 1) * page_size).limit(page_size)
    # @page_meta = PageMeta.new(articles, articles_count, '/articles', page, page_size)

    @dto = ArticleListDto.new(articles, articles_count, self.request.path, page, page_size)
    render :list
  end

  def likes
    @likes_count = @article.likes.count
    @likes = @article.likes
    render 'likes/list'
  end

  def by_author_id
    if params[:author_id].blank?
      # render :json, success: false, messages: {full_messages: 'username not provided'}
      render_error({username: 'Username not provided'})
    end
    @articles = Article.where(user: User.where(id: params[:author_id]))
    render :list
  end

  def by_author
    if params[:username].blank?
      # render :json, success: false, messages: {full_messages: 'username not provided'}
      @dto = ErrorResponse.new({username: 'Username not provided'})
      render :'shared/errors'
    end

    #@articles = Article.where(user: User.where(username: params[:username]))
    @articles = Article.from_user(params[:username])
    render :list
  end

  def by_tag
    if params[:name].blank?
      # render json: {success: false, messages: {full_messages: ['You have to provide a tag name']}}
      render_error({username: 'Username not provided'})
    end

    page_size = 10
    if params[:page].blank?
      page = 1
    else
      page = params[:page].to_i
    end

    @articles = Article.tagged_with(params[:tag])

    @dto = ArticleListDto.new(articles, @articles.count, self.request.path, page, page_size)
    render :list
  end

  def by_tag_id
    if params[:name].blank?
      # render json: {success: false, messages: {full_messages: ['You have to provide a tag name']}}
      render_error({username: 'Username not provided'})
    end

    page_size = 10
    if params[:page].blank?
      page = 1
    else
      page = params[:page].to_i
    end

    @articles = Article.tagged_with(params[:tag])

    @dto = ArticleListDto.new(articles, @articles.count, self.request.path, page, page_size)
    render :list
  end

  def by_category
    if params[:name].blank?
      # render json: {success: false, messages: {full_messages: ['You have to provide a tag name']}}
      render_error({tags: 'You have to provide a tag name'})
    end
    @articles = Article.categorised_as(params[:name])
    render :list
  end


  def by_category_id
  end

  def create
    @dto = ArticleCreateEditDto.new(params)

    tags = get_or_create_tags @dto
    categories = get_or_create_categories @dto

    @article = Article.new(@dto.get_params)
    @article.user = @current_user

    @article.categories = categories unless categories.blank?
    @article.tags = tags unless tags.blank?

    if @article.save
      render :show
    else
      render_error(@article.errors)
      # render json: {success: false, errors: @article.errors, full_messages: @article.errors.full_messages}, status: :unprocessable_entity
    end
  end


  # TODO: Load likes count
  # GET /articles/1
  def show
  end

  def article_by_id
    render :show
  end

  # PATCH/PUT /articles/1
  def update
    # make sure the user owns the article he is trying to update

    @dto = ArticleCreateEditDto.new(params)

    tags = get_or_create_tags @dto
    categories = get_or_create_categories @dto

    params = @dto.get_params.merge!(tags: tags, categories: categories)
    if @article.update_attributes(params)
      render :show
    else
      render_error(@article.errors)
    end
  end

  # DELETE /articles/1
  def destroy
    if @article.destroy
      # render json: {success: true, errors: {full_messages: ['Article deleted successfully']}}
      render_success('Deleted successfully')
    else
      render json: {success: false, errors: {article: 'Permission denied'}}, status: :permission_denied
      # TODO: permission issue?
      render_error({delete: 'Operation failed'})
    end
  end

  def ensure_ownership
    # If the user does not worn the article or he is not admin
    if @article.user == @current_user || @current_user.is_admin?
    else
      render_error('Permission denied')
    end
  end

  def has_author_or_admin_role
    if @current_user.blank? || (!@current_user.is_author? && !@current_user.is_admin?)
      render_error({auth: 'Permission denied'})
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_article
    # check if id is id or slug
    if !!(params[:id] =~ /\A[-+]?[0-9]+\z/)
      # is integer, so id, get by id
      @article = Article.find(params[:id])
    else
      @article = Article.find_by(slug: params[:id])
    end

    #@article = Article.find_by_slug(params[:slug])
  end

  # Only allow a trusted parameter "white list" through.
  def article_params
    params.require(:article).permit(:title, :body, :categories, :tags)
  end

  def debug
    render json: {success: true, params: params}
  end

  def get_or_create_tags(dto)
    tags = []
    if dto.has_tags?
      tags_dto = @dto.get_tags
      tags_dto.each do |tag|
        tags.append Tag.create_with(description: tag[:description] || '').find_or_create_by(name: tag[:name])
      end
    end
    tags
  end

  def get_or_create_categories(dto)
    categories = []
    if dto.has_categories?
      categories_dto = @dto.get_categories
      categories_dto.each do |category|
        categories.append Category.create_with(description: category[:description] || '').find_or_create_by(name: category[:name])
      end
    end
    categories
  end
end
