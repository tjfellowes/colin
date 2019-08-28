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
      container_location: {include: {location: { include: :parent }}}
    })
  end

  get '/api/container/:serial_number' do
    content_type :json
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.
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
        container_location: {include: {location: { include: :parent }}}
      })
    else
      halt(404, "Container with serial number #{params[:serial_number]} not found.")
    end
  end

  get '/api/container/create' do
    if params[:cas].nil?
      halt(422, 'Must provide a CAS number for the chemical in the container.')
    else
      if Colin::Models::Chemical.exists?(cas: params[:cas])
        chemical = Colin::Models::Chemical.where(cas: params[:cas]).take
      else
        chemical = Colin::Models::Chemical.create(cas: params[:cas], prefix: params[:prefix], name: params[:name], haz_substance: params[:haz_substance], un_number: params[:un_number], dg_class_id: params[:dg_class_id], dg_class_2_id: params[:dg_class_2_id], dg_class_3_id: params[:dg_class_3_id], schedule_id: params[:schedule_id], packing_group_id: params[:packing_group_id], created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, name_fulltext: params[:prefix] + params[:name])
      end

      if Colin::Models::Location.exists?(name_fulltext: params[:location])
        location = Colin::Models::Location.where(name_fulltext: params[:location]).take
      else
        location = Colin::Models::Location.create(name: params[:location])
      end

      if Colin::Models::Supplier.exists?(name: params[:supplier])
        supplier = Colin::Models::Supplier.where(name: params[:supplier]).take
      else
        supplier = Colin::Models::Supplier.create(name: params[:supplier])
      end

      container = Colin::Models::Container.create(serial_number: params[:serial_number], container_size: params[:container_size], size_unit: params[:size_unit], date_purchased: Time.now.utc.iso8601, chemical_id: chemical.id, supplier_id: supplier.id)

      Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: location.id).to_json()

      #container = Colin::Models::Container.create(serial_number: params[:serial_number], container_size: params[:container_size], size_unit: params[:size_unit], date_purchased: Time.now.utc.iso8601, chemical_id: chemical.id, supplier_id: params[:supplier_id])

      #Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: params[:location_id]).to_json()
    end
  end

  get '/api/container/update/:serial_number' do
    if params[:serial_number].nil?
      halt(422, 'Must provide a serial number for the container.')
    else
      container = Colin::Models::Container.where(serial_number: params[:serial_number]).take
      Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: params[:location_id], temp: params[:temp]).to_json()
    end
  end

  get '/api/container/delete/:serial_number' do
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
        container_location: {include: {location: { include: :parent }}}
      })
    else
      halt(404, "Container with id #{params[:id]} not found.")
    end
  end

  get '/api/container/location_id/:location_id' do
    content_type :json
    if params[:location_id] == '0'
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
        container_location: {include: {location: { include: :parent }}}
      })
    else
      Colin::Models::Container.joins('LEFT JOIN container_locations i ON i.container_id = containers.id AND i.id = (SELECT MAX(id) FROM container_locations WHERE container_locations.container_id = i.container_id)').where('i.location_id' => params[:location_id]).includes(
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
        container_location: {include: {location: { include: :parent }}}
      })
    end
  end

  get '/api/container/search/:query' do
    content_type :json
      Colin::Models::Container.joins('LEFT JOIN container_locations i ON i.container_id = containers.id AND i.id = (SELECT MAX(id) FROM container_locations WHERE container_locations.container_id = i.container_id) INNER JOIN chemicals ON containers.chemical_id = chemicals.id').where("chemicals.name_fulltext LIKE :query OR serial_number LIKE :query OR chemicals.cas LIKE :query", { query: "%#{params[:query]}%"}).includes(
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
        container_location: {include: {location: { include: :parent }}}
      })
  end
end
