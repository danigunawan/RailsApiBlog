# rails generate scaffold Comment content:string
class CommentsController < ApplicationController
  #before_action :authenticate_user!, except: [:index]

  before_action :set_article!
  before_action :set_comment, only: [:show, :update, :destroy]
  before_action :ensure_ownership, only: [:update, :destroy]


  # GET /comments
  def index
    # @comments = @article.comments.order(created_at: :desc)
    # @comments_count = @comments.count


    page_size = 10
    if params[:page].blank?
      page = 1
    else
      page = params[:page].to_i
    end

    @comments = @article.comments.order(created_at: :desc).offset((page - 1) * page_size).limit(page_size)
    @comments_count = @article.comments.count
    # @page_meta = PageMeta.new(@articles, @articles_count, '/articles', page, page_size)

    @dto = CommentListDto.new(@comments, @comments_count, '/articles' + @article.slug + '/comments', page, page_size)
    render :list
  end

  # POST /comments
  def create
    dto = CommentRequestDto.new(comment_params)
    if dto.valid?
      @comment = @article.comments.new(comment_params)
      @comment.user = @current_user

      if @comment.save
        render :show
      else
        @dto = ErrorResponse.new({create: 'Problems saving the comment'})
        render :'shared/errors'
      end
    else
      @dto = ErrorResponse.new(dto.get_errors)
      render :'shared/errors'
    end
  end


  # PATCH/PUT /comments/1
  def update
    dto = CommentRequestDto.new(comment_params)
    if dto.valid?
      if @comment.update(comment_params)
        render :show
      else
        # render :json, success: false, messages: {full_messages: 'Failed to update comment'}
        @dto = ErrorResponse.new({db: 'Something weird happend'})
        render 'shared/errors'
      end
    else
      @dto = ErrorResponse.new(dto.get_errors)
      render 'shared/errors'
    end

  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
    @dto = SuccessResponse.new('Deleted successfully')
    render :'shared/success'
    # render json: {success: true, messages: {full_messages: ['Deleted successfully']}}
  end

  def ensure_ownership
    if @comment.user_id == @current_user.id || @current_user.is_admin?
    else
      render json: {success: false, errors: {comment: 'Permission Denied'}}, status: :forbidden
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def comment_params
    params.require(:comment).permit(:content)
  end

  private

  def set_article!
    # check if id is id or slug
    if !!(params[:article_id] =~ /\A[-+]?[0-9]+\z/)
      # is integer, so id, get by id
      @article = Article.find(params[:article_id])
    else
      @article = Article.find_by(slug: params[:article_id])
    end

    #@article = Article.find_by_slug(params[:slug])
  end
end
