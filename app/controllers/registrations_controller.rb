class RegistrationsController < Devise::RegistrationsController
    def new
        super
    end
    
    def create
        @user = User.new(:email => 'test@example.com', :password => 'password', :password_confirmation => 'password')
        @user.save
        render json: {success: true, messages: ['Cool', params[:username]]}
    end
    
    def update
        super
    end
end