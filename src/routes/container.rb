require 'sinatra/base'
require 'time'
#
# Routes for Container model
#
# blep
#
class Colin::Routes::Container < Colin::BaseWebApp

  get '/api/container/barcode/:barcode' do
    content_type :json
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:barcode].nil?
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

  # Gets ALL containers
  get '/api/container/all' do
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

  post '/api/container' do
    content_type :json

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:cas].nil?
      halt(422, 'Must provide a CAS for the chemical in the container.')
    else
      #Does the chemical in the container exist already in the database? Identified by CAS
      if Colin::Models::Chemical.exists?(cas: params[:cas])
        chemical = Colin::Models::Chemical.where(cas: params[:cas]).take
      else
        chemical = Colin::Models::Chemical.create_chemical(params)
      end

      # if Colin::Models::Location.exists?(name_fulltext: params[:location])
      #   location = Colin::Models::Location.where(name_fulltext: params[:location]).take
      # elsif Colin::Models::Location.exists?(code: params[:location])
      #   location = Colin::Models::Location.where(code: params[:location]).take
      # else
      #   location = Colin::Models::Location.create(name: params[:location], name_fulltext: params[:location])
      # end

      if params[:supplier].nil?
        #Nothing to do here!
      elsif Colin::Models::Supplier.exists?(name: params[:supplier])
        supplier = Colin::Models::Supplier.where(name: params[:supplier]).take
      else
        supplier = Colin::Models::Supplier.create(name: params[:supplier])
      end

      Colin::Models::Container.create(barcode: params[:barcode], description: params[:description], container_size: params[:container_size], size_unit: params[:size_unit], date_purchased: Time.now.utc.iso8601, chemical_id: chemical.id, supplier_id: supplier.id)

      #Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: location.id).to_json()

    end
  end

  delete '/api/container/barcode/:barcode' do
    content_type :json
    
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:barcode].nil?
      halt(422, 'Must provide a barcode for the container.')
    else
      container = Colin::Models::Container.where(serial_number: params[:serial_number]).take
      Colin::Models::Container.update(container.id, {date_disposed: Time.now})
    end
  end

  get '/api/container/search/:query' do
    content_type :json
    
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    content_type :json
    Colin::Models::Container.joins('LEFT JOIN container_locations i ON i.container_id = containers.id AND i.id = (SELECT MAX(id) FROM container_locations WHERE container_locations.container_id = i.container_id) INNER JOIN chemicals ON containers.chemical_id = chemicals.id').where("chemicals.name_fulltext ILIKE :query OR serial_number LIKE :query OR chemicals.cas LIKE :query", { query: "%#{params[:query]}%"}).includes(
      chemical: [
        {dg_class: :superclass},
        {dg_class_2: :superclass},
        {dg_class_3: :superclass},
        schedule: {},
        packing_group: {}],
      supplier: {},
      container_location: {location: :parent}
    ).to_json(include: {
      chemical: {
        include: {
          schedule: {},
          packing_group: {},
          dg_class: {include: :superclass},
          dg_class_2: {include: :superclass},
          dg_class_3: {include: :superclass},
        }
      },
      supplier: {},
      container_location: {include: {location: { include: :parent }}},
      current_location: {include: {location: { include: :parent }}},
      storage_location: {include: {location: { include: :parent }}}
    })
  end
end
