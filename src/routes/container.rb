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
      chemical: {include: {container_chemical: {}}},
      supplier: {},
      container_location: {include: {location: { include: :parent }}}
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
    elsif Colin::Models::Container.unscoped.exists?(barcode: params[:barcode])
      Colin::Models::Container.unscoped.where("barcode = ?", params[:barcode]).to_json(include: {
        chemical: {
          include: {
            schedule: {},
            packing_group: {},
            signal_word: {},
            chemical_haz_class: { include: :haz_class },
            chemical_pictogram: { include: { pictogram: {except: :picture} } },
            chemical_haz_stat: { include: :haz_stat },
            chemical_prec_stat: { include: :prec_stat },
            dg_class_1: { include: :superclass },
            dg_class_2: { include: :superclass },
            dg_class_3: { include: :superclass },
            container_chemical: {}
          }
        },
        supplier: {},
        container_location: {include: {location: { include: :parent }}}
      })
    else
      halt(404, "Container with barcode #{params[:barcode]} not found.")
    end
  end

  # Create a new container
  post '/api/container' do
    unless session[:authorized] && current_user.can_create_container?
      halt(403, 'Not authorised.')
    end

    content_type :json

    if params[:cas].blank?
      halt(422, 'Must provide a CAS for the chemical in the container.')
    else
      #Does the chemical in the container exist already in the database? Identified by CAS
      if Colin::Models::Chemical.exists?(cas: params[:cas])
        chemical = Colin::Models::Chemical.where(cas: params[:cas]).take
      else
        if params[:cas].blank?
          throw(:halt, [422, 'Must provide a CAS for the chemical.'])
        elsif Colin::Models::Chemical.exists?(cas: params[:cas])
          chemical = Colin::Models::Chemical.where(cas: params[:cas]).take
        else
          #If not, get the safety information supplied and use it to create a new chemical
    
          if params[:name].blank?
            throw(:halt, [422, 'Must provide a name for the chemical.'])
          end
    
          if params[:haz_substance].blank? || params[:haz_substance] == 'false'
            haz_substance = false
          elsif params[:haz_substance] == 'true'
            haz_substance = true
          else
            throw(:halt, [422, 'Invalid hazardous substance value.'])
          end
    
          #Parse the DG class string into dg_class_1, 2 and 3
          if !params[:dg_class].blank?
            dg_class_1, dg_class_2, dg_class_3 = params[:dg_class].strip.split(/ *\( *| *, *| *\) *| +/).map { |number| Colin::Models::DgClass.where(number: number).take if !number.nil? && Colin::Models::DgClass.exists?(number: number)}
          end
    
          if params[:dg_class_1].blank?
            #Nothing to do here!
          elsif Colin::Models::DgClass.exists?(number: params[:dg_class_1])
            dg_class_1 = Colin::Models::DgClass.where(number: params[:dg_class_1]).take
          else
            throw(:halt, [422, 'Invalid dangerous goods class.'])
          end
    
          if params[:dg_class_2].blank?
            #Nothing to do here!
          elsif Colin::Models::DgClass.exists?(number: params[:dg_class_2])
            dg_class_2 = Colin::Models::DgClass.where(number: params[:dg_class_2]).take
          else
            throw(:halt, [422, 'Invalid dangerous goods subclass.'])
          end
    
          if params[:dg_class_3].blank?
            #Nothing to do here!
          elsif Colin::Models::DgClass.exists?(number: params[:dg_class_3])
            dg_class_3 = Colin::Models::DgClass.where(number: params[:dg_class_3]).take
          else
            throw(:halt, [422, 'Invalid dangerous goods subsubclass.'])
          end
    
          if params[:storage_temperature].blank?
            #Nothing to do here!
          elsif params[:storage_temperature].split('~').length == 1
            storage_temperature_min = params[:storage_temperature]
            storage_temperature_max = params[:storage_temperature]
          else
            storage_temperature_min = params[:storage_temperature].split('~').min
            storage_temperature_max = params[:storage_temperature].split('~').max
          end
    
          chemical = Colin::Models::Chemical.create(
            cas: params[:cas], 
            prefix: params[:prefix], 
            name: params[:name], 
            haz_substance: haz_substance, 
            un_number: params[:un_number], 
            un_proper_shipping_name: params[:un_proper_shipping_name],
            signal_word: Colin::Models::SignalWord.find_by(name: params[:signal_word]),
            haz_class: Colin::Models::HazClass.where(id: params[:haz_class_ids]),
            pictogram: Colin::Models::Pictogram.where(id: params[:pictogram_ids]),
            haz_stat: Colin::Models::HazStat.where(code: params[:haz_stats]),
            prec_stat: Colin::Models::PrecStat.where(code: params[:prec_stats]),
            dg_class_1: dg_class_1, 
            dg_class_2: dg_class_2, 
            dg_class_3: dg_class_3, 
            schedule: Colin::Models::Schedule.find_by(number: params[:schedule]),
            packing_group: Colin::Models::PackingGroup.find_by(name: params[:packing_group]),
            storage_temperature_min: storage_temperature_min, 
            storage_temperature_max: storage_temperature_max, 
            inchi: params[:inchi],
            smiles: params[:smiles],
            pubchem: params[:pubchem],
            density: params[:density],
            melting_point: params[:melting_point],
            boiling_point: params[:boiling_point],
            sds: params[:sds],
            created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601
          )    
        
          #The chemical has now been created!
        end
      end

      if params[:supplier].blank?
        #Nothing to do here!
      elsif Colin::Models::Supplier.exists?(name: params[:supplier])
        supplier_id = Colin::Models::Supplier.where(name: params[:supplier]).take.id
      else
        supplier_id = Colin::Models::Supplier.create(name: params[:supplier]).id
      end

      # Parse the quantity into numbers and units
      if !params[:quantity].blank?
        container_size, size_unit = params[:quantity].strip.split(/(?: +|(?:(?<=\d)(?=[a-z]))|(?:(?<=[a-z])(?=\d)))/)
      else
        container_size, size_unit = params[:container_size], params[:size_unit]
      end

      if !params[:barcode].blank?
        barcode = params[:barcode]
      else
        barcode = Colin::Models::Container.unscoped.all.select(:barcode).map{|i| i.barcode.to_i}.max + 1
      end

      container = Colin::Models::Container.create(
        barcode: barcode, 
        description: params[:description], 
        container_size: container_size, 
        size_unit: size_unit, 
        date_purchased: Time.now.utc.iso8601, 
        chemical: Array(chemical), 
        supplier_id: supplier_id, 
        product_number: params[:product_number], 
        lot_number: params[:lot_number], 
        owner_id: params[:owner_id], 
        user_id: current_user.id,
        location: Array(Colin::Models::Location.find(params[:location_id]))
      )

      container.to_json(include: {
        chemical: {
          include: {
            schedule: {},
            packing_group: {},
            signal_word: {},
            chemical_haz_class: { include: :haz_class },
            chemical_pictogram: { include: { pictogram: {except: :picture} } },
            chemical_haz_stat: { include: :haz_stat },
            chemical_prec_stat: { include: :prec_stat },
            dg_class_1: { include: :superclass },
            dg_class_2: { include: :superclass },
            dg_class_3: { include: :superclass }
          }
        },
        supplier: {},
        container_location: {include: {location: { include: :parent }}},
        current_location: {include: {location: { include: :parent }}}
      })
    end
  end


  # Gets containers in a given location id
  get '/api/container/location_id/:location_id' do
    content_type :json
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:location_id].blank?
      halt(422, 'Must provide a location_id.')
    elsif Colin::Models::Location.exists?(id: params[:location_id])
      Colin::Models::Container.joins('LEFT JOIN container_locations i ON i.container_id = containers.id AND
        i.id = (SELECT MAX(id) FROM container_locations WHERE container_locations.container_id = i.container_id)
        INNER JOIN chemicals ON containers.chemical_id = chemicals.id').where("i.location_id = ?", params[:location_id]).to_json(include: {
          chemical: {},
          supplier: {},
          current_location: {}
        })
    else
      halt(404, "Location with location_id #{params[:location_id]} not found.")
    end
  end

  # Edits a container
  put '/api/container/barcode/:barcode' do

    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.

    unless session[:authorized] && current_user.can_edit_container?
      halt(403, 'Not authorised.')
    end

    content_type :json

    if params[:barcode].blank?
      halt(422, 'Must provide a barcode for container.')
    elsif Colin::Models::Container.unscoped.exists?(barcode: params[:barcode])
      container = Colin::Models::Container.unscoped.where(barcode: params[:barcode]).take

      if params[:new_barcode].blank?
        params[:new_barcode] = params[:barcode]
      end

      #Update the supplier
      if params[:supplier].blank?
        #Nothing to do here!
      elsif Colin::Models::Supplier.exists?(name: params[:supplier])
        supplier_id = Colin::Models::Supplier.where(name: params[:supplier]).take.id
      else
        supplier_id = Colin::Models::Supplier.create(name: params[:supplier]).id
      end

      #Update the location
      if params[:location_id].blank?
        halt(422, 'Must provide a location for the container.')
      end

      #Update the container size

      if !params[:quantity].blank?
        container_size, size_unit = params[:quantity].strip.split(/(?: +|(?:(?<=\d)(?=[a-z]))|(?:(?<=[a-z])(?=\d)))/)
      else
        container_size, size_unit = params[:container_size], params[:size_unit]
      end

      container.update(barcode: params[:new_barcode], container_size: container_size, size_unit: size_unit, product_number: params[:product_number], lot_number: params[:lot_number], owner_id: params[:owner_id], supplier_id: supplier_id, user_id: current_user.id, date_disposed: nil)

      Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: params[:location_id])

      container.to_json(include: {
        chemical: {
          include: {
            schedule: {},
            packing_group: {},
            signal_word: {},
            chemical_haz_class: { include: :haz_class },
            chemical_pictogram: { include: { pictogram: {except: :picture} } },
            chemical_haz_stat: { include: :haz_stat },
            chemical_prec_stat: { include: :prec_stat },
            dg_class_1: { include: :superclass },
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

  # Deletes a container
  delete '/api/container/barcode/:barcode' do
    unless session[:authorized] && current_user.can_edit_container?
      halt(403, 'Not authorised.')
    end

    content_type :json

    if params[:barcode].blank?
      halt(422, 'Must provide a barcode for the container.')
    else
      Colin::Models::Container.where(barcode: params[:barcode]).take.update(date_disposed: Time.now)
      status 204
      body ''
    end
  end

  # Undeletes a previously deleted container
  post '/api/container/barcode/:barcode' do
    unless session[:authorized] && current_user.can_edit_container?
      halt(403, 'Not authorised.')
    end

    content_type :json

    if params[:barcode].blank?
      halt(422, 'Must provide a barcode for the container.')
    else
      Colin::Models::Container.unscoped.where(barcode: params[:barcode]).take.update(date_disposed: nil).to_json()
    end
  end

  get '/api/container/search' do
    content_type :json
    
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    content_type :json
    Colin::Models::Container.joins('LEFT JOIN container_locations i ON i.container_id = containers.id AND i.id = (SELECT MAX(id) FROM container_locations WHERE container_locations.container_id = i.container_id) INNER JOIN chemicals ON containers.chemical_id = chemicals.id').where("CONCAT(chemicals.prefix, chemicals.name) ILIKE :query OR barcode LIKE :query OR chemicals.cas LIKE :query", { query: "%"+params[:query]+"%"}).limit(params[:limit]).offset(params[:offset]).to_json(include: {
      chemical: {},
      supplier: {},
      current_location: {}
    })
  end

end
