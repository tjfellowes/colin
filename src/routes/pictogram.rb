require 'sinatra/base'
require 'time'
#
# Routes for Pictogram model
#
# blep
#
class Colin::Routes::Pictogram < Colin::BaseWebApp
    get '/api/pictogram' do 
        unless session[:authorized]
            halt(403, 'Not authorised.')
        end
        content_type :json
        Colin::Models::Pictogram.all.select(:id, :code, :name, :picture).to_json()
    end  

    get '/api/pictogram/image/id/:id' do 
        unless session[:authorized]
          halt(403, 'Not authorised.')
        end
        content_type 'image/jpeg'
        Base64.decode64(Colin::Models::Pictogram.find(params[:id]).picture)
      end
end


