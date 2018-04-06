require 'sinatra/base'

#
# Routes for Container model
#
class Colin::Routes::Container < Sinatra::Base
  #
  # Gets the specified container with the given ID.
  #
  get '/api/container/:id' do
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.
    if params[:id].nil?
      halt(422, 'Must provide an numerical ID for container.')
    elsif Colin::Models::Container.exists?(params[:id])
      Colin::Models::Container.find(params[:id]).to_json
    else
      halt(404, "Container with id #{params[:id]} not found.")
    end
  end

  post '/api/container/:id' do
  end
end
