require 'sinatra/base'
require 'time'
#
# Routes for DgClass model
#
class Colin::Routes::DgClass < Colin::BaseWebApp
    get '/api/dg_class' do 
        unless session[:authorized]
            halt(403, 'Not authorised.')
        end
        content_type :json
        Colin::Models::DgClass.all.includes(:subclasses).to_json(include: :subclasses)
    end  
end


