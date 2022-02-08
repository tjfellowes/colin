require 'sinatra/base'
require 'time'
#
# Routes for Location model
#
# blep
#
class Colin::Routes::Image < Colin::BaseWebApp

  get '/api/image/pictogram/:id' do 
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end
    content_type 'image/jpeg'
    Colin::Models::Pictogram.find(params[:id]).picture
  end

end




