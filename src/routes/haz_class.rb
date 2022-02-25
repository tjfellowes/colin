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
        Colin::Models::HazClass.all.to_json(include: {subclasses: {}, superclass: {}})
    end  

    get '/api/haz_class/id/:id' do 
        unless session[:authorized]
          halt(403, 'Not authorised.')
        end
        content_type :json
        Colin::Models::HazClass.find(params[:id]).to_json(include: {subclasses: {}, superclass: {}})
      end
end


