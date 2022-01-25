require 'sinatra/base'
require 'time'
#
# Routes for Location model
#
# blep
#
class Colin::Routes::Location < Colin::BaseWebApp

  get '/api/location/id/:id' do 
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end
    if params[:id].present?
      content_type :json
      Colin::Models::Location.find_by(id: params[:id]).to_json()
    else
      halt(422, "You must supply a location ID.")
    end
  end

  get '/api/location/barcode/:barcode' do
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end
    if params[:barcode].present?
      content_type :json
      Colin::Models::Location.find_by(barcode: params[:barcode]).to_json()
    else
      halt(422, "You must supply a barcode.")
    end
  end

  get '/api/location/search' do
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end
    if params[:query].present?
      content_type :json
      Colin::Models::Location.where("name ILIKE :query OR barcode LIKE :query", { query: "%"+params[:query]+"%"}).map{|i| i.path.select(:id, :name)}.to_json()
    else
      halt(422, "You must supply a search query.")
    end
  end

  post '/api/location' do
    if params[:monitored].blank? || params[:monitored] == 'false'
      monitored = false
    elsif params[:monitored] == 'true'
      monitored = true
    else
      throw(:halt, [422, 'Invalid monitored value.'])
    end

    if params[:name].blank?
      halt(422, 'Must provide a name for the location.')
    elsif params[:parent_id].present?
      location_type = Colin::Models::LocationType.find(params[:location_type_id])
      parent = Colin::Models::Location.find(params[:parent_id])
      location = Colin::Models::Location.create(name: params[:name], barcode: params[:barcode], temperature: params[:temperature], location_type: location_type, monitored: monitored, parent: parent)
    else
      location_type = Colin::Models::LocationType.find(params[:location_type_id])
      location = Colin::Models::Location.create(name: params[:name], barcode: params[:barcode], temperature: params[:temperature], location_type: location_type, monitored: monitored)
    end
    flash[:message] = "Location created!"
    redirect to '/location/new'
  end

  post '/api/location/id/:id' do
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end
    if params[:id].blank?
      halt(422, "You must supply a location ID.")
    end
    if params[:monitored].blank? || params[:monitored] == 'false'
      monitored = false
    elsif params[:monitored] == 'true'
      monitored = true
    else
      throw(:halt, [422, 'Invalid monitored value.'])
    end

    if params[:name].blank?
      halt(422, 'Must provide a name for the location.')
    else
      location_type = Colin::Models::LocationType.where(name: params[:location_type]).take
      location = Colin::Models::Location.create(name: name.strip, code: params[:code], barcode: params[:barcode], temperature: params[:temperature], location_type: location_type, monitored: monitored, parent_id: parent_id)
    end
    flash[:message] = "Location updated!"
    redirect to '/location/edit'
  end

  delete '/api/location/id/:id' do
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end
    if params[:id].blank?
      halt(422, "You must supply a location ID.")
    end
    Colin::Models::Location.delete(params[:id])
    flash[:message] = "Location deleted!"
    redirect to '/'
  end
end
