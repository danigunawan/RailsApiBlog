# Introduction 
Rails Blog api application, not finished

# Getting started
1. Git clone
2. rails db:drop db:create db:migrate
# Features implemented
- Seeding with faker all models
- Some controllers are implemented: Like, Following/Followers, Articles, Comments

# TODO
- Check if likes models work
- Create a method in app_controller that generates success and error responses
- Improve the sql queries, at this point in time, it is horrible, everything is lazy loaded and for a /articles/slug it triggers 5+ selects ...
- Decide if slug should be not modifiable by requests
- Relations models
- Deny subscribing to users other than authors
- Review UserValidator
- Seed:seedLikes get users that have not liked an article

