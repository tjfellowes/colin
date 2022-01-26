require 'sinatra/base'
require 'time'
#
# Routes for LocationType model
#
# blep
#
class Colin::Routes::LocationType < Colin::BaseWebApp
    get '/api/locationtype' do 
        unless session[:authorized]
            halt(403, 'Not authorised.')
        end
        content_type :json
        Colin::Models::LocationType.all.to_json()
    end  
end


