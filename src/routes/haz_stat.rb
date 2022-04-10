require 'sinatra/base'
require 'time'
#
# Routes for HazStat model
#
class Colin::Routes::HazStat < Colin::BaseWebApp
    get '/api/haz_stat' do 
        unless session[:authorized]
            halt(403, 'Not authorised.')
        end
        content_type :json
        Colin::Models::HazStat.all.to_json()
    end  
end

