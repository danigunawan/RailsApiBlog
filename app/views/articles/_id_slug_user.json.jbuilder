json.(article, :id, :slug)
json.user article.user, partial: 'users/id_username', as: :user
