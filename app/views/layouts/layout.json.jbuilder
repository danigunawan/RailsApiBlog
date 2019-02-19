json.request do
    json.message "Operation completed successfully"
    #json.status 200
end
json.data JSON.parse(yield)

# https://stackoverflow.com/questions/11516616/rails-json-api-layouts-with-jbuilder-or-other