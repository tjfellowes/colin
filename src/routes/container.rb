require 'sinatra/base'
require 'time'
#
# Routes for Container model
#
# blep
#
class Colin::Routes::Container < Colin::BaseWebApp
  #
  # Gets ALL containers
  #
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
        #If not, get the safety information supplied and use it to create a new chemical
        if params[:dg_class].nil?
          #Nothing to do here!
        elsif Colin::Models::DgClass.exists?(number: params[:dg_class])
          dg_class = Colin::Models::DgClass.where(number: params[:dg_class]).take
        else
          halt(422, 'Invalid dangerous goods class')
        end

        if params[:dg_class_2].nil?
          #Nothing to do here!
        elsif Colin::Models::DgClass.exists?(number: params[:dg_class_2])
          dg_class_2 = Colin::Models::DgClass.where(number: params[:dg_class_2]).take
        else
          halt(422, 'Invalid dangerous goods subclass')
        end

        if params[:dg_class_3].nil?
          #Nothing to do here!
        elsif Colin::Models::DgClass.exists?(number: params[:dg_class_3])
          dg_class_3 = Colin::Models::DgClass.where(number: params[:dg_class_3]).take
        else
          halt(422, 'Invalid dangerous goods subsubclass')
        end

        if params[:schedule].nil?
          #Nothing to do here!
        elsif Colin::Models::Schedule.exists?(number: params[:schedule])
          schedule = Colin::Models::Schedule.where(number: params[:schedule]).take
        else
          halt(422, 'Invalid schedule')
        end

        if params[:packing_group].nil?
          #Nothing to do here!
        elsif Colin::Models::PackingGroup.exists?(name: params[:schedule])
          packing_group = Colin::Models::PackingGroup.where(name: params[:schedule]).take
        else
          halt(422, 'Invalid packing group')
        end

        if params[:signal_word].nil?
          #Nothing to do here!
        elsif Colin::Models::SignalWord.exists?(name: params[:signal_word])
          signal_word = Colin::Models::SignalWord.where(name: params[:signal_word]).take
        else
          halt(422, 'Invalid signal word')
        end

        chemical = Colin::Models::Chemical.create(
          cas: params[:cas], 
          prefix: params[:prefix], 
          name: params[:name], 
          haz_substance: params[:haz_substance], 
          un_number: params[:un_number], 
          un_proper_shipping_name: params[:un_proper_shipping_name],
          dg_class: dg_class, 
          dg_class_2: dg_class_2, 
          dg_class_3: dg_class_3, 
          schedule: schedule, 
          packing_group: packing_group,
          storage_temperature_min: params[:storage_temperature_min], 
          storage_temperature_max: params[:storage_temperature_max], 
          inchi: params[:inchi],
          smiles: params[:smiles],
          pubchem: params[:pubchem],
          density: params[:density],
          melting_point: params[:melting_point],
          boiling_point: params[:boiling_point],
          sds: params[:sds],
          created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601
        )

        #Now that we have an instance of the chemical, we can deal with foreign keys

        if params[:haz_stat].nil?
          #Nothing to do here!
        else
          for i in params[:haz_stat].split(':')
            if Colin::Models::HazStat.exists?(code: i)
              haz_stat = Colin::Models::HazStat.where(code: i).take
              Colin::Models::ChemicalHazStat.create!(chemical_id: chemical.id, haz_stat_id: haz_stat.id)
            else
              halt(422, "Invalid H statement code #{i} (supply as colon separated list)")
            end
          end
        end

        if params[:prec_stat].nil?
          #Nothing to do here!
        else
          for i in params[:prec_stat].split(':')
            if Colin::Models::PrecStat.exists?(code: i.split(',')[0])
              prec_stat = Colin::Models::PrecStat.where(code: i.split(',')[0]).take
              chemical_prec_stat = Colin::Models::ChemicalPrecStat.create!(chemical_id: chemical.id, prec_stat_id: prec_stat.id)
              n = 1
              for j in i.split(',').drop(1)
                Colin::Models::ChemicalPrecStatSupp.create!(chemical_prec_stat_id: chemical_prec_stat.id, position: n, information: j)
                n=n+1
              end
            else
              halt(422, "Invalid P statement code #{i.split(',')[0]} (supply as colon separated list)")
            end
          end
        end

        if params[:haz_class].nil?
          #Nothing to do here!
        else
          for i in params[:haz_class].split(':')
            if Colin::Models::HazClass.exists?(description: i.split(',')[0])
              haz_class = Colin::Models::HazClass.where(description: i.split(',')[0]).take
              category = i.split(',')[1]
              chemical_haz_class = Colin::Models::ChemicalHazClass.create!(chemical_id: chemical.id, haz_class_id: haz_class.id, category: category)
            else
              halt(422, "Invalid hazard classification #{i.split(',')[0]} (supply as colon separated list)")
            end
          end
        end

        if params[:pictogram].nil?
          #Nothing to do here!
        else
          for i in params[:pictogram].split(':')
            if Colin::Models::Pictogram.exists?(name: i)
              pictogram = Colin::Models::Pictogram.where(code: i).take
              Colin::Models::ChemicalPictogram.create!(chemical_id: chemical.id, pictogram_id: pictogram.id)
            else
              halt(422, "Invalid pictogram name #{i} (supply as colon separated list)")
            end
          end
        end

        #The chemical has now been created!
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

  delete '/api/container/serial/:serial_number' do
    content_type :json
    
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:serial_number].nil?
      halt(422, 'Must provide a serial number for the container.')
    else
      container = Colin::Models::Container.where(serial_number: params[:serial_number]).take
      Colin::Models::Container.update(container.id, {date_disposed: Time.now})
    end
  end

  get '/api/container/id/:id' do
    content_type :json
    
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.
    if params[:id].nil?
      halt(422, 'Must provide an numerical ID for container.')
    elsif Colin::Models::Container.exists?(params[:id])
      Colin::Models::Container.find(params[:id]).to_json(include: {
        chemical: {
          include: {
            schedule: {},
            packing_group: {},
            dg_class: {include: :superclass},
            dg_class_2: {include: :superclass},
            dg_class_3: {include: :superclass}
          }
        },
        supplier: {},
        container_location: {include: {location: { include: :parent }}},
        current_location: {include: {location: { include: :parent }}},
        storage_location: {include: {location: { include: :parent }}}
      })
    else
      halt(404, "Container with id #{params[:id]} not found.")
    end
  end

  get '/api/container/location/:location' do
    content_type :json
    
    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if Colin::Models::Location.exists?(name_fulltext: params[:location])
      location = Colin::Models::Location.where(name_fulltext: params[:location]).take
      location_id = location.id
    elsif Colin::Models::Location.exists?(code: params[:location])
      location = Colin::Models::Location.where(code: params[:location]).take
      location_id = location.id
    elsif params[:location] == 'Missing'
      location_id = '0'
    else
      halt(404,"Location not found.")
    end

    if location_id == '0'
      Colin::Models::Container.joins('LEFT JOIN container_locations i ON i.container_id = containers.id AND i.id = (SELECT MAX(id) FROM container_locations WHERE container_locations.container_id = i.container_id)').where('i.location_id' => nil).includes(
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
            dg_class_3: {include: :superclass}
          }
        },
        supplier: {},
        container_location: {include: {location: { include: :parent }}},
        current_location: {include: {location: { include: :parent }}},
        storage_location: {include: {location: { include: :parent }}}
      })
    else
      Colin::Models::Container.joins('LEFT JOIN container_locations i ON i.container_id = containers.id AND i.id = (SELECT MAX(id) FROM container_locations WHERE container_locations.container_id = i.container_id)').where('i.location_id' => location_id).includes(
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
            dg_class_3: {include: :superclass}
          }
        },
        supplier: {},
        container_location: {include: {location: { include: :parent }}},
        current_location: {include: {location: { include: :parent }}},
        storage_location: {include: {location: { include: :parent }}}
      })
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
