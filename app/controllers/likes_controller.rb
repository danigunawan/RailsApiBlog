class LikesController < ApplicationController

  before_action :set_article!

  def likes
    @likes_count = @article.likes.count
    @likes = @article.likes
    render :list
  end

  def like
    if @article.users_liked.include?(@current_user)
      @dto = ErrorResponse.new('You already upvoted it')
      render :'shared/errors'
      # render json: {success: false, errors: {full_messages: ['You already upvoted it']}}
    else
      @article.users_liked << @current_user
      @dto = SuccessResponse.new('Liked successfully')
      render :'shared/success'
    end
  end

  def unlike
    if @article.users_liked.include?(@current_user)
      success = @article.users_liked.delete(@current_user)
      @dto = SuccessResponse.new('Unliked successfully')
      render :'shared/success'
    else
      @dto = ErrorResponse.new({like: 'You have not liked this yet'})
      render :'shared/errors'
      # render json: {success: false, errors: {full_messages: ['You have not liked this yet']}}
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_article!
    # check if id is id or slug
    if !!(params[:article_id_or_slug] =~ /\A[-+]?[0-9]+\z/)
      # is integer, so id, get by id
      @article = Article.find(params[:article_id_or_slug])
    else
      @article = Article.find_by(slug: params[:article_id_or_slug])
      #@article = Article.find_by_slug(params[:article_id_or_slug])
    end
  end
end
