json.(comment, :id, :content, :created_at, :updated_at)
# Not needed json.article comment.article, partial: 'articles/id_slug_user', as: :article
json.user comment.user, partial: 'users/id_username', as: :user
