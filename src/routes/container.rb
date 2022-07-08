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
    Colin::Models::Container.limit(params[:limit]).offset(params[:offset]).includes(:container_content, :chemical, :supplier, :container_location, :location).to_json(include: {
      container_content: {
        include: {
          chemical: {}
        }
      },
      supplier: {},
      container_location: {
        include: {
          location: {}
        }
      }
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
        container_content: {
          include: {
            chemical: {
              include: {
                dg_class_1: {},
                dg_class_2: {},
                dg_class_3: {},
                schedule: {},
                signal_word: {},
                haz_class: {include: :superclass},
                haz_stat: {},
                prec_stat: {},
                pictogram: {except: :picture}
              }
            }
          }
        },
        supplier: {},
        dg_class_1: {},
        dg_class_2: {},
        dg_class_3: {},
        schedule: {},
        signal_word: {},
        haz_class: {include: :superclass},
        haz_stat: {},
        prec_stat: {},
        pictogram: {except: :picture},
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

    components = JSON.parse(params[:components])
    
    #Maybe validate some fields???

    #Check if chemicals with the given cas numbers exist already, if not, create them
    for component in components
      unless Colin::Models::Chemical.where(cas: component['cas']).exists?

        for i in component
          puts(i)
        end

        #Parse the storage temperature into a max and min
        if component['storage_temperature'].blank?
          storage_temperature_min = 25
          storage_temperature_max = 25
        elsif component['storage_temperature'].split('~').length == 1
          storage_temperature_min = component['storage_temperature']
          storage_temperature_max = component['storage_temperature']
        else
          storage_temperature_min = component['storage_temperature'].split('~').min
          storage_temperature_max = component['storage_temperature'].split('~').max
        end

        chemical = Colin::Models::Chemical.create(
          cas: component['cas'],
          name: component['name'],
          prefix: component['prefix'],
          haz_substance: component['haz_substance'],
          dg_class_1: Colin::Models::DgClass.find_by_id(component['dg_class_1_id']),
          dg_class_2: Colin::Models::DgClass.find_by_id(component['dg_class_2_id']),
          dg_class_3: Colin::Models::DgClass.find_by_id(component['dg_class_3_id']),
          packing_group: Colin::Models::PackingGroup.find_by_id(component['packing_group_id']),
          un_number: component['un_number'],
          un_proper_shipping_name: component['un_proper_shipping_name'],
          schedule: Colin::Models::Schedule.find_by_id(component['schedule_id']),
          storage_temperature_min: storage_temperature_min,
          storage_temperature_max: storage_temperature_max,
          inchi: component['inchi'],
          smiles: component['smiles'],
          pubchem: component['pubchem'],
          density: component['density'],
          melting_point: component['melting_point'],
          boiling_point: component['boiling_point'],
          signal_word: Colin::Models::SignalWord.find_by_id(component['signal_word_id'])
        )

        puts(chemical.take)

        unless component['haz_stats'].blank?
          chemical.update(haz_stat: Array(Colin::Models::HazStat.find(Array(component['haz_stats']).map{ |i| i['id']})))
        end
    
        unless component['prec_stats'].blank?
          chemical.update(prec_stat: Array(Colin::Models::PrecStat.find(Array(component['prec_stats']).map{ |i| i['id']})))
        end
    
        unless component['haz_class_ids'].blank?
          chemical.update(haz_class: Array(Colin::Models::HazClass.find(Array(component['haz_class_ids']).map{ |i| i['id']})))
        end
    
        unless component['pictograms'].blank?
          chemical.update(pictogram: Array(Colin::Models::Pictogram.find(Array(component['pictograms']).map{ |i| i['id']})))
        end

      end
    end

    first_chemical = Colin::Models::Chemical.where(cas: components[0]['cas']).take

    # Parse the quantity into numbers and units
    unless params[:container_size].blank?
      container_size_number, container_size_unit = params[:quantity].strip.split(/(?: +|(?:(?<=\d)(?=[a-z]))|(?:(?<=[a-z])(?=\d)))/)
    else
      container_size_number, container_size_unit = params[:container_size_number], params[:container_size_unit]
    end

    #Generate a barcode if one is not supplied
    unless params[:barcode].blank?
      barcode = params[:barcode]
    else
      barcode = Colin::Models::Container.unscoped.all.select(:barcode).map{|i| i.barcode.to_i}.max + 1
    end

    if !params[:storage_temperature].blank?
      if params[:storage_temperature].split('~').length == 1
        storage_temperature_min = params[:storage_temperature]
        storage_temperature_max = params[:storage_temperature]
      else
        storage_temperature_min = params[:storage_temperature].split('~').min
        storage_temperature_max = params[:storage_temperature].split('~').max
      end
    elsif !first_chemical['storage_temperature'].blank?
      if first_chemical['storage_temperature'].split('~').length == 1
        storage_temperature_min = first_chemical['storage_temperature']
        storage_temperature_max = first_chemical['storage_temperature']
      else
        storage_temperature_min = first_chemical['storage_temperature'].split('~').min
        storage_temperature_max = first_chemical['storage_temperature'].split('~').max
      end
    else
      storage_temperature_min = 25
      storage_temperature_max = 25
    end

    unless params[:name].blank?
      name = params[:name]
    else
      name = first_chemical.name
    end

    unless params[:prefix].blank?
      prefix = params[:prefix]
    else
      prefix = first_chemical.prefix
    end

    unless params[:haz_substance].blank?
      haz_substance = params[:haz_substance]
    else
      haz_substance = first_chemical.haz_substance
    end

    unless params[:dg_class_1_id].blank?
      dg_class_1_id = params[:dg_class_1_id]
    else
      dg_class_1_id = first_chemical.dg_class_1_id
    end

    unless params[:dg_class_2_id].blank?
      dg_class_2_id = params[:dg_class_2_id]
    else
      dg_class_2_id = first_chemical.dg_class_2_id
    end

    unless params[:dg_class_3_id].blank?
      dg_class_3_id = params[:dg_class_3_id]
    else
      dg_class_3_id = first_chemical.dg_class_3_id
    end

    unless params[:dg_class_3_id].blank?
      dg_class_3_id = params[:dg_class_3_id]
    else
      dg_class_3_id = first_chemical.dg_class_3_id
    end

    unless params[:packing_group_id].blank?
      packing_group_id = params[:packing_group_id]
    else
      packing_group_id = first_chemical.packing_group_id
    end

    unless params[:un_number].blank?
      un_number = params[:un_number]
    else
      un_number = first_chemical.un_number
    end

    unless params[:un_proper_shipping_name].blank?
      un_proper_shipping_name = params[:un_proper_shipping_name]
    else
      un_proper_shipping_name = first_chemical.un_proper_shipping_name
    end

    unless params[:schedule_id].blank?
      schedule_id = params[:schedule_id]
    else
      schedule_id = first_chemical.schedule_id
    end

    unless params[:density].blank?
      density = params[:density]
    else
      density = first_chemical.density
    end

    unless params[:melting_point].blank?
      melting_point = params[:melting_point]
    else
      melting_point = first_chemical.melting_point
    end

    unless params[:boiling_point].blank?
      boiling_point = params[:boiling_point]
    else
      boiling_point = first_chemical.boiling_point
    end
    
    unless params[:signal_word_id].blank?
      signal_word_id = params[:signal_word_id]
    else
      signal_word_id = first_chemical.signal_word_id
    end

    unless params[:haz_stat].blank?
      haz_stat = JSON.parse(params[:haz_stat])
    end
    

    #Create the container
    container = Colin::Models::Container.create(
      location: Array(Colin::Models::Location.find_by_id(params[:location_id])),
      supplier: Colin::Models::Supplier.find_by_id(params[:supplier_id]), 
      container_size_number: container_size_number, 
      container_size_unit: container_size_unit, 
      barcode: barcode, 
      product_number: params[:product_number], 
      lot_number: params[:lot_number], 
      owner: Colin::Models::User.find(params[:owner_id]), 
      date_purchased: Time.now.utc.iso8601, 
      user_id: current_user.id,
      name: name,
      prefix: prefix,
      description: params[:description], 
      haz_substance: haz_substance,
      dg_class_1: Colin::Models::DgClass.find_by_id(dg_class_1_id),
      dg_class_2: Colin::Models::DgClass.find_by_id(dg_class_2_id),
      dg_class_3: Colin::Models::DgClass.find_by_id(dg_class_3_id),
      packing_group: Colin::Models::PackingGroup.find_by_id(packing_group_id),
      un_number: un_number,
      un_proper_shipping_name: un_proper_shipping_name,
      schedule: Colin::Models::Schedule.find_by_id(schedule_id),
      storage_temperature_min: storage_temperature_min,
      storage_temperature_max: storage_temperature_max,
      density: density,
      melting_point: melting_point,
      boiling_point: boiling_point,
      sds: params[:sds],
      signal_word: Colin::Models::SignalWord.find_by_id(signal_word_id),
      chemical: Colin::Models::Chemical.where(cas: Array(components.map{ |i| i['cas']}))
    )

    unless params[:haz_stat].blank?
      container.update(haz_stat: Array(Colin::Models::HazStat.find(Array(JSON.parse(params[:haz_stat])).map{ |i| i['id']})))
    else
      unless first_chemical.haz_stat.blank?
        container.update(haz_stat: Array(Colin::Models::HazStat.find(first_chemical.haz_stat.map{ |i| i['id']})))
      end
    end

    unless params[:prec_stat].blank?
      container.update(prec_stat: Array(Colin::Models::PrecStat.find(Array(JSON.parse(params[:prec_stat])).map{ |i| i['id']})))
    else
      unless first_chemical.prec_stat.blank?
        container.update(prec_stat: Array(Colin::Models::PrecStat.find(first_chemical.prec_stat.map{ |i| i['id']})))
      end
    end

    unless params[:haz_class].blank?
      container.update(haz_class: Array(Colin::Models::HazClass.find(Array(JSON.parse(params[:haz_class])).map{ |i| i['id']})))
    else
      unless first_chemical.haz_class.blank?
        container.update(haz_class: Array(Colin::Models::HazClass.find(first_chemical.haz_class.map{ |i| i['id']})))
      end
    end

    unless params[:pictogram].blank?
      container.update(pictogram: Array(Colin::Models::Pictogram.find(Array(JSON.parse(params[:pictogram])).map{ |i| i['id']})))
    else
      unless first_chemical.pictogram.blank?
        container.update(pictogram: Array(Colin::Models::Pictogram.find(first_chemical.pictogram.map{ |i| i['id']})))
      end
    end

    #Return the container as a JSON string
    container.to_json(include: {
      container_content: {
        include: {
          chemical: {
            include: {
              dg_class_1: {},
              dg_class_2: {},
              dg_class_3: {},
              schedule: {},
              signal_word: {},
              haz_class: {include: :superclass},
              haz_stat: {},
              prec_stat: {},
              pictogram: {except: :picture}
            }
          }
        }
      },
      supplier: {},
      dg_class_1: {},
      dg_class_2: {},
      dg_class_3: {},
      schedule: {},
      signal_word: {},
      haz_class: {include: :superclass},
      haz_stat: {},
      prec_stat: {},
      pictogram: {except: :picture},
      container_location: {include: {location: { include: :parent }}},
      current_location: {include: {location: { include: :parent }}}
    })
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
        INNER JOIN chemicals ON containers.chemical_id = chemicals.id').where("i.location_id = ?", params[:location_id]).includes(:container_content, :chemical, :supplier, :container_location, :location).to_json(include: {
          container_content: {
            include: {
              chemical: {}
            }
          },
          supplier: {},
          container_location: {include: {location: {}}}
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
        container_content: {
          include: {
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
            }
          }
        },
        supplier: {},
        container_location: {include: {location: { include: :parent }}}
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
    Colin::Models::Container.joins('LEFT JOIN container_locations i ON i.container_id = containers.id AND i.id = (SELECT MAX(id) FROM container_locations WHERE container_locations.container_id = i.container_id) INNER JOIN container_contents ON container_contents.container_id = containers.id INNER JOIN chemicals ON container_contents.chemical_id = chemicals.id').where("CONCAT(chemicals.prefix, chemicals.name) ILIKE :query OR barcode LIKE :query OR chemicals.cas LIKE :query", { query: "%"+params[:query]+"%"})
  end

end
