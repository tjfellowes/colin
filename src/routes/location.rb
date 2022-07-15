require 'sinatra/base'
require 'time'
#
# Routes for Location model
#
# blep
#
class Colin::Routes::Location < Colin::BaseWebApp

  get '/api/location' do 
    content_type :json

    unless session[:authorized]
      halt(401, 'Not authorised.')
    end
    
    locations = Colin::Models::Location.active
    Colin::Models::Location.sort_by_ancestry(locations).to_json(
      methods: :location_path, 
      include: :location_type
    )
  end


  ###########################################################
  get '/api/location/id/:id' do 
    unless session[:authorized]
      halt(401, 'Not authorised.')
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
      halt(401, 'Not authorised.')
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
      halt(401, 'Not authorised.')
    end
    if params[:query].present?
      content_type :json
      Colin::Models::Location.where("name ILIKE :query OR barcode LIKE :query", { query: "%"+params[:query]+"%"}).map{|i| i.path.select(:id, :name)}.to_json()
    else
      halt(422, "You must supply a search query.")
    end
  end

  # Create a location
  post '/api/location' do
    unless session[:authorized] && current_user.can_create_location?
      halt(401, 'Not authorised.')
    end

    content_type :json

    if params[:monitored].blank? || params[:monitored] == 'false'
      monitored = false
    elsif params[:monitored] == 'true'
      monitored = true
    else
      throw(:halt, [422, 'Invalid monitored value.'])
    end

    if params[:name].blank?
      halt(422, 'Must provide a name for the location.')
    elsif params[:location_type_id].blank?
      halt(422, 'Must provide a location type for the location.')
    elsif !params[:barcode].blank? && Colin::Models::Location.exists?(barcode: params[:barcode])
      halt(422, 'Location with barcode ' + params[:barcode] + ' already exists.')
    elsif !params[:parent_id].blank? && Colin::Models::Location.children_of(params[:parent_id]).exists?(name: params[:name])
      halt(422, 'Location ' + params[:name] + ' in ' + Colin::Models::Location.find(params[:parent_id]).name + ' already exists.')
    elsif params[:parent_id].present?
      location_type = Colin::Models::LocationType.find(params[:location_type_id])
      parent = Colin::Models::Location.find(params[:parent_id])

      Colin::Models::Location.create(id: params[:id], name: params[:name], barcode: params[:barcode], temperature: params[:temperature], location_type: location_type, monitored: monitored, parent: parent).to_json()
    else
      location_type = Colin::Models::LocationType.find(params[:location_type_id])

      Colin::Models::Location.create(id: params[:id], name: params[:name], barcode: params[:barcode], temperature: params[:temperature], location_type: location_type, monitored: monitored).to_json()
    end
  end

  # Update a location
  put '/api/location/id/:id' do
    unless session[:authorized] && current_user.can_edit_location?
      halt(401, 'Not authorised.')
    end

    content_type :json

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
      location = Colin::Models::Location.find(params[:id]).update(name: params[:name], code: params[:code], barcode: params[:barcode], temperature: params[:temperature], location_type_id: params[:location_type_id], monitored: monitored, parent_id: params[:parent_id]).to_json()
    end
  end

  # Delete a location
  delete '/api/location/id/:id' do
    unless session[:authorized] && current_user.can_edit_location?
      halt(401, 'Not authorised.')
    end
    if params[:id].blank?
      halt(422, "You must supply a location ID.")
    end
    Colin::Models::Location.find(params[:id]).update(date_deleted: Time.now)
    status 204
    body ''
  end
end




