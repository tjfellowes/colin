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
    Colin::Models::Container.limit(params[:limit]).offset(params[:offset]).includes(chemical: [{dg_class: :superclass}, {dg_class_2: :superclass}, {dg_class_3: :superclass}, schedule: {}, packing_group: {}], supplier: {}).to_json(include: {
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
      storage_location: {
        include: {
          location: { include: :parent }
        }
      }
      # current_location: {
      #   include: {
      #     location: { include: :parent }
      #   }
      # }
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
        current_location: {
          include: {
            location: { include: :parent }
          }
        },
        storage_location: {
          include: {
            location: { include: :parent }
          }
        }
      })
    else
      halt(404, "Container with serial number #{params[:serial_number]} not found.")
    end
  end

  get '/api/create/container' do
    if params[:cas].nil?
      halt(422, 'Must provide a CAS number for the chemical in the container.')
    else
      if Colin::Models::Chemical.exists?(cas: params[:cas])
        chemical = Colin::Models::Chemical.where(cas: params[:cas]).take
      else
        chemical = Colin::Models::Chemical.create(cas: params[:cas], prefix: params[:prefix], name: params[:name], haz_substance: params[:haz_substance], un_number: params[:un_number], dg_class_id: params[:dg_class_id], dg_class_2_id: params[:dg_class_2_id], dg_class_3_id: params[:dg_class_3_id], schedule_id: params[:schedule_id], packing_group_id: params[:packing_group_id], created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, name_fulltext: params[:prefix] + params[:name])
      end
      container = Colin::Models::Container.create(serial_number: params[:serial_number], container_size: params[:container_size], size_unit: params[:size_unit], date_purchased: Time.now.utc.iso8601, chemical_id: chemical.id, supplier_id: params[:supplier_id])

      Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: params[:location_id]).to_json()
    end
  end

  get '/api/update/container/:serial_number' do
    if params[:serial_number].nil?
      halt(422, 'Must provide a serial number for the container.')
    else
      container = Colin::Models::Container.where(serial_number: params[:serial_number]).take
      Colin::Models::ContainerLocation.create(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: container.id, location_id: params[:location_id], temp: params[:temp]).to_json()
    end
  end

  get '/api/delete/container/:serial_number' do
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
        current_location: {
          include: {
            location: { include: :parent }
          }
        },
        storage_location: {
          include: {
            location: { include: :parent }
          }
        }
      })
    else
      halt(404, "Container with id #{params[:id]} not found.")
    end
  end

  get '/api/container/location_id/:location_id' do
    content_type :json
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.
    if params[:location_id] == '0'
      containers = Colin::Models::ContainerLocation.where(location_id: nil).pluck(:container_id)
      Colin::Models::Container.where(id: containers).includes(
        chemical: [
          {dg_class: :superclass},
          {dg_class_2: :superclass},
          {dg_class_3: :superclass},
          schedule: {},
          packing_group: {}],
        supplier: {}
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
        current_location: {
          include: {
            location: { include: :parent }
          }
        },
        storage_location: {
          include: {
            location: { include: :parent }
          }
        }
      })
    else
      containers = Colin::Models::ContainerLocation.where(location_id: params[:location_id]).pluck(:container_id)
      Colin::Models::Container.where(id: containers).includes(
        chemical: [
          {dg_class: :superclass},
          {dg_class_2: :superclass},
          {dg_class_3: :superclass},
          schedule: {},
          packing_group: {}],
        supplier: {}
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
        current_location: {
          include: {
            location: { include: :parent }
          }
        },
        storage_location: {
          include: {
            location: { include: :parent }
          }
        }
      })
    end
  end

  get '/api/search/container/:query' do
    content_type :json
    if params[:live] == 'true'
      chemicals = Colin::Models::Chemical.where("name_fulltext LIKE :query", query: "%#{params[:query]}%").pluck(:id)
      container = Colin::Models::Container.where(chemical_id: chemicals).or(Colin::Models::Container.where("serial_number LIKE :query", { query: "%#{params[:query]}%"})).includes(
        chemical: [
          {dg_class: :superclass},
          {dg_class_2: :superclass},
          {dg_class_3: :superclass},
          schedule: {},
          packing_group: {}],
        supplier: {}
      ).to_json(include: {
        chemical: {
          include: {
            schedule: {},
            packing_group: {},
            dg_class: {include: :superclass},
            dg_class_2: {include: :superclass},
            dg_class_3: {include: :superclass}
          }
        }
      })
    else
      chemicals = Colin::Models::Chemical.where("name_fulltext LIKE :query", { query: "%#{params[:query]}%"}).pluck(:id)
      container = Colin::Models::Container.where(chemical_id: chemicals).or(Colin::Models::Container.where("serial_number LIKE :query", { query: "%#{params[:query]}%"})).includes(
        chemical: [
          {dg_class: :superclass},
          {dg_class_2: :superclass},
          {dg_class_3: :superclass},
          schedule: {},
          packing_group: {}],
        supplier: {}
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
        storage_location: {
          include: {
            location: { include: :parent }
          }
        }
      })
    end
  end
end
