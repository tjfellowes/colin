require 'sinatra'

#
# The primary web application, COLIN.
#

set :public_folder, 'public'

# Serve static
get '/' do
  redirect '/index.html'
end

# Route for not found
not_found do
  redirect '/404.html'
end

get '/inventory' do
  # shows inventory table
end

get '/inventory/:chem_id' do
  # shows table of instances of chem_id
end

