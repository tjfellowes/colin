require 'sinatra/base'
require 'time'
#
# Routes for PrecStat model
#
class Colin::Routes::PrecStat < Colin::BaseWebApp
    get '/api/prec_stat' do 
        unless session[:authorized]
            halt(403, 'Not authorised.')
        end
        content_type :json
        Colin::Models::PrecStat.all.to_json()
    end  
end


