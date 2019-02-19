json.user do |json|
    success: true,
    json.paprtial! 'users/user', user: current_user 
end