require 'sinatra/base'
require 'time'
#
# Routes for PackingGroup model
#
class Colin::Routes::PackingGroup < Colin::BaseWebApp
    get '/api/packing_group' do 
        unless session[:authorized]
            halt(403, 'Not authorised.')
        end
        content_type :json
        Colin::Models::PackingGroup.all.to_json()
    end  
end


