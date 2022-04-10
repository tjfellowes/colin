require 'sinatra/base'
require 'time'
#
# Routes for Supplier model
#
class Colin::Routes::Supplier < Colin::BaseWebApp
  get '/api/supplier' do 
      unless session[:authorized]
          halt(403, 'Not authorised.')
      end
      content_type :json
      Colin::Models::Supplier.all.to_json()
  end  
end


