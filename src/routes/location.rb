require 'sinatra/base'
require 'time'
#
# Routes for Location model
#
# blep
#
class Colin::Routes::Location < Colin::BaseWebApp

  get '/api/location' do
    #blep
  end

  post '/api/location' do
    if params[:path].blank?
      halt(422, 'Must provide a location for the container.')
    else
      location = nil
      #Split the path up into names delimited by forward slashes
      params[:path].split('/').each do |name|
        #Pick all the locations whose name matches
        locations = Colin::Models::Location.where(name: name).all
        #If there are none we need to create the location!
        if locations.length() == 0
          location = Colin::Models::Location.create(name: name, code: params[:code], temperature: params[:temperature], monitored: params[:monitored], parent: location)
        #If there is one, use that as the location
        elsif locations.length() == 1
          location = locations.take
        #If there is more than one, we need to search again, specifying that the parent id should be the id of the previous location in the path.
        elsif location != nil && Colin::Models::Location.where(name: name).where("reverse(split_part(reverse(ancestry), '/', 1)) = ':parent_id'", {parent_id: location.id}).exists?
            location = Colin::Models::Location.where(name: name).where("reverse(split_part(reverse(ancestry), '/', 1)) = ':parent_id'", {parent_id: location.id}).take
        else
          halt(422, 'Ambiguous location name!')
        end
        #Iterate until we get to the end of the path.
      end 
    end
    flash[:message] = "Location created!"
    redirect to ''
  end

  delete '/api/location' do
    #blep
  end

  get '/newlocation' do
    erb :'locations/new.html'
  end 
end
