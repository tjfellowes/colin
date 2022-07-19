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

    #Check that the session has an authorisation token otherwise return 401.
    unless session[:authorized]
      halt(401, 'Not authorised.')
    end

    #Gets all the containers including chemical info
    Colin::Models::Container.limit(params[:limit]).offset(params[:offset]).includes(
        container_content: {
          chemical: {
            haz_stat: {}, prec_stat: {}, haz_class: {}
          }
        },
        container_location: {
          location: {}
        }
      ).to_json(include: {
        container_content: {
          include: {
            chemical: {
              include: {
                dg_class_1: {include: :superclass},
                dg_class_2: {include: :superclass},
                dg_class_3: {include: :superclass},
                haz_class: {include: :superclass},
                schedule: {},
                packing_group: {},
                haz_stat: {},
                prec_stat: {},
                pictogram: {except: :picture},
                signal_word: {}
              },
              except: :sds
            }
          }
        },
        supplier: {},
        container_location: {
          include: {
            location: {
              methods: :location_path, 
              include: :location_type
            }
          }
        }
      }
    )
  end

  # Create a new container
  post '/api/container' do
    unless session[:authorized] && current_user.can_create_container?
      halt(401, 'Not authorised.')
    end

    content_type :json

    payload = JSON.parse(request.body.read, symbolize_names: true)

    containers = []

    for i in payload

      containers.append(Colin::Models::Container.new(
        barcode: (i[:barcode].blank? ? Colin::Models::Container.where.not(barcode: nil).order(:barcode).last.barcode.to_i + 1 : i[:barcode]),
        container_size_number: i[:container_size_number],
        container_size_unit: i[:container_size_unit],
        date_purchased: (i[:date_purchased].blank? ? Time.now : i[:date_purchased]),
        expiry_date: i[:date_purchased],
        supplier: Colin::Models::Supplier.find_by(id: i[:supplier_id]),
        description: i[:description],
        product_number: i[:product_number],
        lot_number: i[:lot_number],
        user: current_user,
        owner: Colin::Models::User.find_by(id: i[:owner_id]),
        # picture: i[:picture], # Look into active storage for this
        container_content: i[:container_content].map{ |j|
          Colin::Models::ContainerContent.new(
            chemical: ((chemical = Colin::Models::Chemical.where(id: j[:chemical_id]).load).any? ? chemical.take : halt(422, "Chemical with id not found")),
            quantity_number: j[:quantity_number],
            quantity_unit: j[:quantity_unit],
            concentration_number: j[:concentration_number],
            concentration_unit: j[:concentration_unit]
          )
        },
        location: [((location = Colin::Models::Location.where(id: i[:location_id]).load).any? ? location.take : halt(422, "location with id not found"))]
      ))
    end

    if !containers.map{|i| i.save!}.include?(false)
      containers.to_json(include: {
        container_content: {
          include: {
            chemical: {
              include: {
                dg_class_1: {include: :superclass},
                dg_class_2: {include: :superclass},
                dg_class_3: {include: :superclass},
                haz_class: {include: :superclass},
                schedule: {},
                packing_group: {},
                haz_stat: {},
                prec_stat: {},
                pictogram: {except: :picture},
                signal_word: {}
              },
              except: :sds
            }
          }
        },
        supplier: {},
        container_location: {
          include: {
            location: {
              methods: :location_path, 
              include: :location_type
            }
          }
        }
      })
    end
  end

  get '/api/container/id/:id' do
    content_type :json

    #Check that the session has an authorisation token otherwise return 401.
    unless session[:authorized]
      halt(401, 'Not authorised.')
    end

    #Gets all the containers including chemical info
    Colin::Models::Container.includes(
        container_content: {
          chemical: {
            haz_stat: {}, prec_stat: {}, haz_class: {}
          }
        },
        container_location: {
          location: {}
        }
      ).find_by(id: params[:id]).to_json(include: {
        container_content: {
          include: {
            chemical: {
              include: {
                dg_class_1: {include: :superclass},
                dg_class_2: {include: :superclass},
                dg_class_3: {include: :superclass},
                haz_class: {include: :superclass},
                schedule: {},
                packing_group: {},
                haz_stat: {},
                prec_stat: {},
                pictogram: {except: :picture},
                signal_word: {}
              },
              except: :sds
            }
          }
        },
        supplier: {},
        container_location: {
          include: {
            location: {
              methods: :location_path, 
              include: :location_type
            }
          }
        }
      }
    )
  end

  put '/api/container/id/:id' do
    unless session[:authorized] && current_user.can_edit_container?
      halt(401, 'Not authorised.')
    end

    content_type :json

    i = JSON.parse(request.body.read, symbolize_names: true)

    if (container = Colin::Models::Container.find_by(id: params[:id]))
      Colin::Models::ContainerContent.where(container_id: container.id).each do |i| i.delete end
      Colin::Models::ContainerLocation.where(container_id: container.id).each do |i| i.delete end
      container.update(
        barcode: i[:barcode],
        container_size_number: i[:container_size_number],
        container_size_unit: i[:container_size_unit],
        date_purchased: i[:date_purchased],
        expiry_date: i[:expiry_date],
        supplier: Colin::Models::Supplier.find_by(id: i[:supplier_id]),
        description: i[:description],
        product_number: i[:product_number],
        lot_number: i[:lot_number],
        user: current_user,
        owner: Colin::Models::User.find_by(id: i[:owner_id]),
        # picture: i[:picture], # Look into active storage for this
        container_content: i[:container_content].map{ |j|
          Colin::Models::ContainerContent.new(
            chemical: ((chemical = Colin::Models::Chemical.where(id: j[:chemical_id]).load).any? ? chemical.take : halt(422, "Chemical with id not found")),
            quantity_number: j[:quantity_number],
            quantity_unit: j[:quantity_unit],
            concentration_number: j[:concentration_number],
            concentration_unit: j[:concentration_unit]
          )
        },
        container_location: [Colin::Models::ContainerLocation.new(
          location: ((location = Colin::Models::Location.where(id: i[:location_id]).load).any? ? location.take : halt(422, "location with id not found"))
        )]
      )
    end
    return container.to_json(include: {
      container_content: {
        include: {
          chemical: {
            include: {
              dg_class_1: {include: :superclass},
              dg_class_2: {include: :superclass},
              dg_class_3: {include: :superclass},
              haz_class: {include: :superclass},
              schedule: {},
              packing_group: {},
              haz_stat: {},
              prec_stat: {},
              pictogram: {except: :picture},
              signal_word: {}
            },
            except: :sds
          }
        }
      },
      supplier: {},
      container_location: {
        include: {
          location: {
            methods: :location_path, 
            include: :location_type
          }
        }
      }
    })
  end

  patch '/api/container/id/:id' do
    unless session[:authorized] && current_user.can_edit_container?
      halt(401, 'Not authorised.')
    end

    if (container = Colin::Models::Container.with_deleted.find_by(id: params[:id]))
      container.restore
      container.to_json
    else
      halt 422, "Container with given id not found"
    end
  end

  delete '/api/container/id/:id' do
    unless session[:authorized] && current_user.can_edit_container?
      halt(401, 'Not authorised.')
    end
    
    if (container = Colin::Models::Container.find_by(id: params[:id]))
      container.delete
      return 204
    else
      halt 422, "Container with given id not found"
    end
  end
end
