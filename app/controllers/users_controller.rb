# rails generate controller Users
class UsersController < ApplicationController


  before_action :set_user, only: [:show, :update, :destroy]
  # Require authentication for write operations(create, update, destroy)
  before_action :is_authenticated, except: [:index, :show, :create]
  before_action :ensure_ownership, only: [:update, :destroy]

  def index
    @users = User.all
    @users_count = @users.count
    page_size = 10
    if params[:page].blank?
      page = 1
    else
      page = params[:page].to_i
    end
    @users = @users.order(created_at: :desc).offset((page - 1) * page_size).limit(page_size)

    @dto = UserListDto.new(@users, @users_count, '/users', page, page_size)
    render :list
  end

  def show
    render :show
  end

  def create
    register_dto = RegisterDto.new(params)
    if register_dto.valid?
      @user = User.new(register_dto.get_params)

      if @user.save
        @dto = SuccessResponse.new('User created successfully')
        render 'shared/success'
        # render json: {success: true, full_messages: ['Done']}
      else
        @dto = ErrorResponse.new(@user.errors)
        render 'shared/errors'
        # render json: {success: false, full_messages: @user.errors.full_messages}
        # render json: ErrorSerializer.serialize(user.errors), status: 422
      end
    else
      @dto = ErrorResponse.new(register_dto.get_errors)
      render 'shared/errors'
    end
  end

  def update
    # update vs update_attributes
    if @current_user.update_attributes(user_params)
      render :show
    else
      render json: {success: false, errors: {user: @current_user.errors}}, status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :image)
  end

  # DELETE /articles/1
  def destroy
    if @user.destroy
      @dto = SuccessResponse.new('Deleted successfully')
      render :'shared/success'
    else
      render json: {success: false, errors: {article: 'Permission denied'}}, status: :permission_denied
      @dto = ErrorResponse.new({delete: 'Operation failed'})
      render 'shared/errors'
    end
  end

  private

  def ensure_ownership
    # If the user does not worn the article or he is not admin
    if @user == @current_user || @current_user.is_admin?
    else
      @dto = ErrorResponse.new('Permission denied')
      render 'shared/errors'
    end
  end

  def is_authenticated
    if @current_user.blank?
      @dto = ErrorResponse.new({auth: 'Permission denied'})
      render :'shared/errors'
    end
  end


  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def article_params
    params.require(:article).permit(:title, :body, :categories, :tags)
  end
end
