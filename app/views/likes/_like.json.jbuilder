json.(like, :created_at, :article_id)
json.user like.user, partial: 'users/id_username', as: :user
