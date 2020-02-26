require 'sinatra/base'
require 'time'
#
# Routes for Container model
#
# blep
#
class Colin::Routes::Container < Sinatra::Base
  #
  # Gets the specified container with the given ID.
  #
  get '/api/container/all' do
    Colin::Models::Container.limit(params[:limit]).offset(params[:offset]).includes(
        chemical: [
          {dg_class: :superclass},
          {dg_class_2: :superclass},
          {dg_class_3: :superclass},
          schedule: {},
          packing_group: {}],
        supplier: {},
        container_location: {location: :parent}).to_json(include: {
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

  get '/api/container/serial/:serial_number' do
    content_type :json
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:serial_number].nil?
      halt(422, 'Must provide a serial number for container.')
    elsif Colin::Models::Container.exists?(serial_number: params[:serial_number])
      #Colin::Models::Container.where(serial_number: params[:serial_number]).not(:date_disposed.to_s < Time.now.utc.iso8601).to_json(include: {
      Colin::Models::Container.where("serial_number = ?", params[:serial_number]).to_json(include: {
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
      halt(404, "Container with serial number #{params[:serial_number]} not found.")
    end
  end

  post '/api/container/serial/:serial_number' do

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:cas].nil?
      halt(422, 'Must provide a CAS for the chemical in the container.')
    else
      if Colin::Models::Chemical.exists?(cas: params[:cas])
        chemical = Colin::Models::Chemical.where(cas: params[:cas]).take
      else
        if Colin::Models::DgClass.exists?(number: params[:dg_class])
          dg_class_id = Colin::Models::DgClass.where(number: params[:dg_class]).take.id
        end
        if Colin::Models::DgClass.exists?(number: params[:dg_class_2])
          dg_class_2_id = Colin::Models::DgClass.where(number: params[:dg_class_2]).take.id
        end
        if Colin::Models::DgClass.exists?(number: params[:dg_class_3])
          dg_class_3_id = Colin::Models::DgClass.where(number: params[:dg_class_3]).take.id
        end
        if Colin::Models::Schedule.exists?(number: params[:schedule])
          schedule_id = Colin::Models::Schedule.where(number: params[:schedule]).take.id
        end
        if Colin::Models::PackingGroup.exists?(name: params[:schedule])
          packing_group_id = Colin::Models::PackingGroup.where(name: params[:schedule]).take.id
        end

        chemical = Colin::Models::Chemical.create(cas: params[:cas], prefix: params[:prefix], name: params[:name], haz_substance: params[:haz_substance], un_number: params[:un_number], dg_class_id: dg_class_id, dg_class_2_id: dg_class_2_id, dg_class_3_id: dg_class_3_id, schedule_id: schedule_id, packing_group_id: packing_group_id, created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, name_fulltext: params[:prefix] + params[:name])
      end

      if Colin::Models::Location.exists?(name_fulltext: params[:location])
        location = Colin::Models::Location.where(name_fulltext: params[:location]).take
      elsif Colin::Models::Location.exists?(code: params[:location])
        location = Colin::Models::Location.where(code: params[:location]).take
      else
        location = Colin::Models::Location.create(name: params[:location], name_fulltext: params[:location])
      end

      if Colin::Models::Supplier.exists?(name: params[:supplier])
        supplier = Colin::Models::Supplier.where(name: params[:supplier]).take
      else
        supplier = Colin::Models::Supplier.create(name: params[:supplier])
      end

      #Comment for initial import script using location id's
      container = Colin::Models::Container.create(serial_number: params[:serial_number], description: params[:description], container_size: params[:container_size], size_unit: params[:size_unit], date_purchased: Time.now.utc.iso8601, chemical_id: chemical.id, supplier_id: supplier.id)

      Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: location.id).to_json()

      #Uncomment for initial import script using location id's
      #container = Colin::Models::Container.create(serial_number: params[:serial_number], container_size: params[:container_size], size_unit: params[:size_unit], date_purchased: Time.now.utc.iso8601, chemical_id: chemical.id, supplier_id: params[:supplier_id])

      #Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: params[:location_id]).to_json()
    end
  end

  put '/api/container/serial/:serial_number' do

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    if params[:serial_number].nil?
      halt(422, 'Must provide a serial number for the container.')
    elsif params[:serial_number] == "quit"
      #do nothing
    else
      container = Colin::Models::Container.where(serial_number: params[:serial_number]).take
      unless params[:location].nil?
        if Colin::Models::Location.exists?(name_fulltext: params[:location])
          location = Colin::Models::Location.where(name_fulltext: params[:location]).take
        elsif Colin::Models::Location.exists?(code: params[:location])
        location = Colin::Models::Location.where(code: params[:location]).take
        else
          location = Colin::Models::Location.create(name: params[:location], name_fulltext: params[:location])
        end
        Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: location.id, temp: params[:temp])
      end

      unless params[:description].nil?
        container.update(description: params[:description])
      end

      Colin::Models::Container.where("serial_number = ?", params[:serial_number]).to_json(include: {
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

  delete '/api/container/serial/:serial_number' do

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

    if session[:authorized]
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
    else
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
        container_location: {},
        current_location: {},
        storage_location: {}
      })
    end
  end
end
