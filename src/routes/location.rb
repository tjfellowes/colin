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
    
    locations = Colin::Models::Location.all
    Colin::Models::Location.sort_by_ancestry(locations).to_json(
      methods: :location_path, 
      include: :location_type
    )
  end

  post '/api/location' do
    content_type :json

    unless session[:authorized] && current_user.can_create_location?
      halt(401, 'Not authorised.')
    end

    payload = JSON.parse(request.body.read, symbolize_names: true)

    locations = []

    for i in payload
      locations.append(Colin::Models::Location.new(
        name: i[:name],
        code: i[:code],
        barcode: i[:barcode],
        location_type: Colin::Models::LocationType.find_by(id: i[:location_type_id]),
        temperature: i[:temperature],
        monitored: i[:monitored],
        parent: Colin::Models::Location.find_by(id: i[:parent_id])
      ))
    end
    
    if !locations.map{|i| i.save}.include?(false)
      return locations.to_json(
        include: {
          location_type: {}
        }
      )
    else
      halt 500, "Could not save locations to the database"
    end
  end

  get '/api/location/id/:id' do
    content_type :json

    unless session[:authorized]
      halt(401, 'Not authorised.')
    end
    
    Colin::Models::Location.find_by(id: params[:id]).to_json(
      methods: :location_path, 
      include: :location_type
    )
  end

  # Update a location
  put '/api/location/id/:id' do
    content_type :json
    unless session[:authorized] && current_user.can_edit_location?
      halt(401, 'Not authorised.')
    end

    i = JSON.parse(request.body.read, symbolize_names: true)

    if (location = Colin::Models::Location.find_by(id: params[:id]))
      location.update!(
        name: i[:name],
        code: i[:code],
        barcode: i[:barcode],
        location_type: Colin::Models::LocationType.find_by(id: i[:location_type_id]),
        temperature: i[:temperature],
        monitored: i[:monitored],
        parent: Colin::Models::Location.find_by(id: i[:parent_id])
      )
      return location.to_json(
        include: {
          location_type: {}
        }
      )
    else
      halt 422, "Location with given id not found"
    end
  end

  # Update a location by its id - At the moment this can only undelete a location.
  patch '/api/location/id/:id' do
    content_type :json
    unless session[:authorized] && current_user.can_edit_location?
      halt(401, 'Not authorised.')
    end

    if (location = Colin::Models::Location.with_deleted.find_by(id: params[:id]))
      location.restore
      location.to_json(
        methods: :location_path, 
        include: :location_type
      )
    else
      halt 422, "Location with given id not found"
    end
  end

  # Delete a location
  delete '/api/location/id/:id' do
    unless session[:authorized] && current_user.can_edit_location?
      halt(401, 'Not authorised.')
    end
    if (location = Colin::Models::Location.find_by(id: params[:id]))
      location.delete
      return 204
    else
      halt 422, "Location with given id not found"
    end
  end  

  
end




