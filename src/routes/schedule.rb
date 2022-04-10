require 'sinatra/base'
require 'time'
#
# Routes for Schedule model
#
class Colin::Routes::Schedule < Colin::BaseWebApp
    get '/api/schedule' do 
        unless session[:authorized]
            halt(403, 'Not authorised.')
        end
        content_type :json
        Colin::Models::Schedule.all.to_json()
    end  
end


