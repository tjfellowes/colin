require 'sinatra/base'
require 'time'
#
# Routes for HazClass model
#
# blep
#
class Colin::Routes::HazClass < Colin::BaseWebApp
    get '/api/haz_class' do 
        unless session[:authorized]
            halt(403, 'Not authorised.')
        end
        content_type :json
        Colin::Models::HazClass.all.includes(:subclasses, :superclass).to_json(include: {subclasses: {}, superclass: {}})
    end  
end


