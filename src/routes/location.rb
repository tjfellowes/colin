require 'sinatra/base'
require 'time'
#
# Routes for Location model
#
# blep
#
class Colin::Routes::Location < Sinatra::Base
  get '/api/location/:location' do
    if params[:location].nil?
      halt(422, 'Must provide a name or code for the location.')
    elsif Colin::Models::Location.exists?(name_fulltext: params[:location])
      Colin::Models::Location.where('name_fulltext = ?', params[:location]).to_json()
    elsif Colin::Models::Location.exists?(code: params[:location])
      Colin::Models::Location.where('code = ?', params[:location]).to_json()
    else
      halt(404, "Location not found.")
    end
  end

  post '/api/location/' do
    #blep
  end

  put '/api/location/:location' do
    if params[:location].nil?
      halt(422, 'Must provide a name for the location.')
    elsif Colin::Models::Location.exists?(name_fulltext: params[:location])
      Colin::Models::Location.where('name_fulltext = ?', params[:location]).update(code: params[:code]).to_json()
    else
      halt(404, "Location not found.")
    end
  end

  delete '/api/location/' do
    #blep
  end
end
