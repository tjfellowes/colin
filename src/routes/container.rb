require 'sinatra/base'
require 'time'
#
# Routes for Container model
#
# blep
#
class Colin::Routes::Container < Colin::BaseWebApp

  # Gets ALL containers
  get '/api/container' do
    content_type :json

    #Check that the session has an authorisation token otherwise return 403.
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    #Gets all the containers including chemical info
    Colin::Models::Container.limit(params[:limit]).offset(params[:offset]).to_json(include: {
      chemical: {},
      current_location: {include: {location: {include: :path}}}
    })
  end

  # Gets a specific container by barcode
  get '/api/container/barcode/:barcode' do
    content_type :json
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:barcode].blank?
      halt(422, 'Must provide a barcode for container.')
    elsif Colin::Models::Container.exists?(barcode: params[:barcode])
      Colin::Models::Container.where("barcode = ?", params[:barcode]).to_json(include: {
        chemical: {
        include: {
          schedule: {},
          packing_group: {},
          signal_word: {},
          chemical_haz_class: { include: :haz_class },
          chemical_pictogram: { include: { pictogram: {except: :picture} } },
          chemical_haz_stat: { include: :haz_stat },
          chemical_prec_stat: { include: :prec_stat },
          dg_class: { include: :superclass },
          dg_class_2: { include: :superclass },
          dg_class_3: { include: :superclass }
        }
      },
        supplier: {},
        container_location: {include: {location: { include: :parent }}},
        current_location: {include: {location: { include: :parent }}}
      })
    else
      halt(404, "Container with barcode #{params[:barcode]} not found.")
    end
  end

  post '/api/container/edit/barcode/:barcode' do
    content_type :json
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:barcode].blank?
      halt(422, 'Must provide a barcode for container.')
    elsif Colin::Models::Container.exists?(barcode: params[:barcode])
      if params[:new_barcode].blank?
        halt(422, 'Must provide a barcode for container.')
      else

        #Update the supplier
        if params[:supplier].blank?
          #Nothing to do here!
        elsif Colin::Models::Supplier.exists?(name: params[:supplier])
          supplier = Colin::Models::Supplier.where(name: params[:supplier]).take
        else
          supplier = Colin::Models::Supplier.create(name: params[:supplier])
        end

        #Update the location
        if params[:location].blank?
          halt(422, 'Must provide a location for the container.')
        else
          location = nil
          #Split the path up into names delimited by forward slashes
          params[:location].split('/').each do |name|
            #Pick all the locations whose name matches
            locations = Colin::Models::Location.where(name: name).all
            #If there are none something has gone wrong!
            if locations.length() == 0
              halt(422, 'Invalid location!')
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

        #Update the container size

        container_size, size_unit = params[:quantity].split

        container = Colin::Models::Container.where("barcode = ?", params[:barcode]).update(barcode: params[:new_barcode], container_size: container_size, size_unit: size_unit, product_number: params[:product_number], lot_number: params[:lot_number], owner_id: params[:owner_id], supplier_id: supplier.id, user_id: current_user.id).first

        Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: location.id)
      end
    else
      halt(404, "Container with barcode #{params[:barcode]} not found.")
    end
    flash[:message] = "Chemical updated!"
    redirect to '/container/barcode/' + params[:new_barcode]
  end

  post '/api/container' do
    content_type :json

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:cas].blank?
      halt(422, 'Must provide a CAS for the chemical in the container.')
    else
      #Does the chemical in the container exist already in the database? Identified by CAS
      if Colin::Models::Chemical.exists?(cas: params[:cas])
        chemical = Colin::Models::Chemical.where(cas: params[:cas]).take
      else
        chemical = Colin::Models::Chemical.create_chemical(params)
      end

      if params[:location].blank?
        halt(422, 'Must provide a location for the container.')
      else
        location = nil
        #Split the path up into names delimited by forward slashes
        params[:location].split('/').each do |name|
          #Pick all the locations whose name matches
          locations = Colin::Models::Location.where(name: name).all
          #If there are none something has gone wrong!
          if locations.length() == 0
            halt(422, 'Invalid location!')
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

      if params[:supplier].blank?
        #Nothing to do here!
      elsif Colin::Models::Supplier.exists?(name: params[:supplier])
        supplier_id = Colin::Models::Supplier.where(name: params[:supplier]).take.id
      else
        supplier_id = Colin::Models::Supplier.create(name: params[:supplier]).id
      end

      container = Colin::Models::Container.create(barcode: params[:barcode], description: params[:description], container_size: params[:container_size], size_unit: params[:size_unit], date_purchased: Time.now.utc.iso8601, chemical_id: chemical.id, supplier_id: supplier_id, product_number: params[:product_number], lot_number: params[:lot_number], owner_id: params[:owner_id], user_id: current_user.id)

      Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: location.id)

    end
    flash[:message] = "Chemical created!"
    redirect to ''
  end

  post '/api/container/delete/barcode/:barcode' do
    content_type :json
    
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:barcode].blank?
      halt(422, 'Must provide a barcode for the container.')
    else
      container = Colin::Models::Container.where(barcode: params[:barcode]).take
      Colin::Models::Container.update(container.id, {date_disposed: Time.now})
    end
  end

  get '/api/container/search/:query' do
    content_type :json
    
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    content_type :json
    search_containers(params[:query]).to_json(include: {
      chemical: {
        include: {
          schedule: {},
          packing_group: {},
          signal_word: {},
          chemical_haz_class: { include: :haz_class },
          chemical_pictogram: { include: { pictogram: {except: :picture} } },
          chemical_haz_stat: { include: :haz_stat },
          chemical_prec_stat: { include: :prec_stat },
          dg_class: { include: :superclass },
          dg_class_2: { include: :superclass },
          dg_class_3: { include: :superclass }
        }
      },
      supplier: {},
      container_location: {include: {location: { include: :parent }}},
      current_location: {include: {location: { include: :parent }}}
    })
  end

  get '/container/search' do
    if params[:query].blank?
      flash[:message] = "Please supply a search query."
      redirect to ''
    else
      erb :'containers/search.html'
    end
  end

  get '/container/new' do
    erb :'containers/new.html'
  end

  get '/container/barcode/:barcode' do
    erb :'containers/detail.html'
  end

  get '/container/edit/barcode/:barcode' do
    erb :'containers/edit.html'
  end
  
end
