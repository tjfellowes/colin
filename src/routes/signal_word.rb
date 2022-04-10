require 'sinatra/base'
require 'time'
#
# Routes for SignalWord model
#
class Colin::Routes::SignalWord < Colin::BaseWebApp
    get '/api/signal_word' do 
        unless session[:authorized]
            halt(403, 'Not authorised.')
        end
        content_type :json
        Colin::Models::SignalWord.all.to_json()
    end  
end


