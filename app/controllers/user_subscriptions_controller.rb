class UserSubscriptionsController < ApplicationController
  before_action :authenticate_user

  def index
    @user_subscriptions = UserSubscription
                              .where(following_id: @current_user.id)
                              .or(UserSubscription.where(follower_id: @current_user.id))
                              .includes(:following).includes(:follower)
                              .all
    @subscriptions_count = @user_subscriptions.count
    page_size = 10
    if params[:page].blank?
      page = 1
    else
      page = params[:page].to_i
    end
    @user_subscriptions = @user_subscriptions.order(created_at: :desc).offset((page - 1) * page_size).limit(page_size)
    @followers = []
    @following = []
    @user_subscriptions.collect do |subscription|
      if subscription.follower_id == @current_user_id
        @following.append subscription.following
      elsif subscription.following_id == @current_user_id
        @followers.append subscription.follower
      end
    end

    @dto = UserSubscriptionsListDto.new(@user_subscriptions, @following, @followers, @subscriptions_count, self.request.path, page, page_size)
    render 'index'
  end

  def followers
    @user_subscriptions = UserSubscription.includes(:follower).where(following_id: @current_user_id).all
    @subscriptions_count = @user_subscriptions.count
    page_size = 10
    if params[:page].blank?
      page = 1
    else
      page = params[:page].to_i
    end
    @user_subscriptions = @user_subscriptions.order(created_at: :desc).offset((page - 1) * page_size).limit(page_size)
    @followers = []
    @user_subscriptions.collect do |subscription|
      @followers.append subscription.follower
    end

    @dto = UserSubscriptionsListDto.new(@user_subscriptions, nil, @followers, @subscriptions_count, self.request.path, page, page_size)
    render 'index'
  end

  def following
    @user_subscriptions = UserSubscription.includes(:following).where(follower_id: @current_user_id).all
    @subscriptions_count = @user_subscriptions.count
    page_size = 10
    if params[:page].blank?
      page = 1
    else
      page = params[:page].to_i
    end
    @user_subscriptions = @user_subscriptions.order(created_at: :desc).offset((page - 1) * page_size).limit(page_size)
    @following = []
    @user_subscriptions.collect do |subscription|
      @following.append subscription.following
    end

    @dto = UserSubscriptionsListDto.new(@user_subscriptions, @following, nil, @subscriptions_count, self.request.path, page, page_size)
    render 'index'
  end

  def subscribe
    id = params[:user_id]
    user = User.find_by_id id
    result = @current_user.subscribe_to user
    if result.errors.blank?
      @dto = SuccessResponse.new ["You have just subscribed to #{user.username}"]
      render 'shared/success'
    else
      @dto = ErrorResponse.new result.errors
      render 'shared/errors'
    end
  end

  def unsubscribe
    id = params[:user_id]
    user = User.find_by_id id
    result = @current_user.unsubscribe_from user
    if result.errors.blank?
      @dto = SuccessResponse.new ["You have just unsubscribed to #{user.username}"]
      render 'shared/success'
    else
      @dto = ErrorResponse.new result.errors
      render 'shared/errors'
    end
  end
end