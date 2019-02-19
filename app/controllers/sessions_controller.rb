class SessionsController < Devise::SessionsController

  def register
    @user = User.new(:email => 'test@example.com', :password => 'password', :password_confirmation => 'password')
    @user.save
    render json: {success: true, messages: ['Cool']}
    user = User.find_by_email(sign_in_params[:email])
    if user && user.valid_password?(sign_in_params[:password])
      @current_user = user
    else
      render json: {success: false, errors: {:credentials => 'invalid'}}, status: :unprocessable_entity
    end
  end

  def login
    if (user = User.where(email: params[:email]))
      if user && user.valid_password?(sign_in_params[:password])
        sign_in(User.find(params[:id]), scope: :user)
      end
    else
      render json: {success: false, errors: {full_messages: ['Invalid credentials']}}
    end
  end

end