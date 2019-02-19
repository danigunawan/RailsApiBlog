Rails.application.routes.draw do
  # rails routes
  # rake routes

  # This is an api app so mount its root to /api
  scope :api, defaults: {format: :json} do
    resources :users do
      post 'login' => 'auth#login', on: :collection

      get '/relations', on: :collection, to: 'user_subscriptions#index'
      get '/relations/following', to: 'user_subscriptions#following', on: :collection
      get '/relations/followers', to: 'user_subscriptions#followers', on: :collection
      post '/relations/followers', to: 'user_subscriptions#subscribe'
      delete '/relations/followers', to: 'user_subscriptions#unsubscribe'
    end


    post '/register', to: 'users#create', as: :register_user
    post '/auth/login', to: 'auth#login'

    resources :articles do

      get 'by_id/:id' => :article_by_id, constraint: {id: /^\d/}, on: :collection

      get 'by_tag/:tag_id' => :by_tag_id, constraint: {tag_id: /^\d/},
          on: :collection
      get 'by_tag/:name' => :by_tag, on: :collection

      get 'by_author_id/:author_id' => :by_author_id, on: :collection
      get 'by_author/:username' => :by_author, on: :collection

      get 'by_category/:name' => :by_category, on: :collection
      get 'by_category_id/:category_id' => :by_category_id, constraint: {by_category_id: /^\d/},
          on: :collection

      resources :comments, except: :show
    end


    # ugly but I don know better than this...
    get '/articles/:article_id_or_slug/likes', to: 'likes#likes'
    post '/articles/:article_id_or_slug/likes', to: 'likes#like'
    delete '/articles/:article_id_or_slug/likes', to: 'likes#unlike'


    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  end
end
