require 'sinatra/base'
require 'time'

#
# Routes for Chemical model
#
class Colin::Routes::Chemical < Colin::BaseWebApp
  #
  # Pagination supported using the `limit' and `offset'
  # query parameters. E.g. GET /chemical?limit=1&offset=15 gets the first page
  # of 15 chemicals. Defaults are page 1 and size 15. 
  #

  #Gets ALL chemicals
  get '/api/chemical' do
    content_type :json

    unless session[:authorized]
      halt(401, 'Not authorised.')
    end

    Colin::Models::Chemical.limit(params[:limit]).offset(params[:offset]).includes({
      dg_class_1: :superclass,
      dg_class_2: :superclass,
      dg_class_3: :superclass,
      schedule: {},
      packing_group: {},
      haz_class: :superclass,
      haz_stat: {},
      prec_stat: {},
      pictogram: {},
      signal_word: {}
    }).to_json(
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
    )
  end

  # Create a chemical
  post '/api/chemical' do
    content_type :json
    unless session[:authorized] && current_user.can_create_container?
      halt(401, 'Not authorised.')
    end

    payload = JSON.parse(request.body.read, symbolize_names: true)

    chemicals = []

    for i in payload

      chemicals.append(Colin::Models::Chemical.new(
        cas: i[:cas],
        prefix: i[:prefix],
        name: i[:name],
        inchi: i[:inchi],
        smiles: i[:smiles],
        pubchem: i[:pubchem],
        density: i[:density],
        melting_point: i[:melting_point],
        boiling_point: i[:boiling_point],
        storage_temperature_min: i[:storage_temperature_min],
        storage_temperature_max: i[:storage_temperature_max],
        haz_substance: i[:haz_substance],
        sds_url: i[:sds_url],
        sds: i[:sds],
        dg_class_1: Colin::Models::DgClass.find_by(id: i[:dg_class_1_id]),
        dg_class_2: Colin::Models::DgClass.find_by(id: i[:dg_class_2_id]),
        dg_class_3: Colin::Models::DgClass.find_by(id: i[:dg_class_3_id]),
        schedule: Colin::Models::Schedule.find_by(id: i[:schedule_id]),
        packing_group: Colin::Models::PackingGroup.find_by(id: i[:packing_group_id]),
        un_number: i[:un_number],
        un_proper_shipping_name: i[:un_proper_shipping_name],
        haz_class: Colin::Models::HazClass.where(id: i[:haz_class_ids]).to_a,
        haz_stat: Colin::Models::HazStat.where(id: i[:haz_stat_ids]).to_a,
        prec_stat: Colin::Models::PrecStat.where(id: i[:prec_stat_ids]).to_a,
        pictogram: Colin::Models::Pictogram.where(id: i[:pictogram_ids]).to_a,
        signal_word: Colin::Models::SignalWord.find_by(id: i[:signal_word_id])
      ))
    end

    if !chemicals.map{|i| i.save!}.include?(false)
      return chemicals.to_json(
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
      )
    else
      halt 500, "Could not save chemicals to the database."
    end
  end

  # Get a specific chemical by id
  get '/api/chemical/id/:id' do
    content_type :json

    unless session[:authorized]
      halt(401, 'Not authorised.')
    end

    Colin::Models::Chemical.includes({
      dg_class_1: :superclass,
      dg_class_2: :superclass,
      dg_class_3: :superclass,
      schedule: {},
      packing_group: {},
      haz_class: :superclass,
      haz_stat: {},
      prec_stat: {},
      pictogram: {},
      signal_word: {}
    }).find_by(id: params[:id]).to_json(
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
    )
  end
  
  # Update a chemical by its id - requires an entire representation of the chemical
  put '/api/chemical/id/:id' do
    content_type :json
    unless session[:authorized] && current_user.can_edit_container?
      halt(401, 'Not authorised.')
    end

    i = JSON.parse(request.body.read, symbolize_names: true)

    if (chemical = Colin::Models::Chemical.find_by(id: params[:id]))
      chemical.update!(
        cas: i[:cas],
        prefix: i[:prefix],
        name: i[:name],
        inchi: i[:inchi],
        smiles: i[:smiles],
        pubchem: i[:pubchem],
        density: i[:density],
        melting_point: i[:melting_point],
        boiling_point: i[:boiling_point],
        storage_temperature_min: i[:storage_temperature_min],
        storage_temperature_max: i[:storage_temperature_max],
        haz_substance: i[:haz_substance],
        sds_url: i[:sds_url],
        sds: i[:sds],
        dg_class_1: Colin::Models::DgClass.find_by(id: i[:dg_class_1_id]),
        dg_class_2: Colin::Models::DgClass.find_by(id: i[:dg_class_2_id]),
        dg_class_3: Colin::Models::DgClass.find_by(id: i[:dg_class_3_id]),
        schedule: Colin::Models::Schedule.find_by(id: i[:schedule_id]),
        packing_group: Colin::Models::PackingGroup.find_by(id: i[:packing_group_id]),
        un_number: i[:un_number],
        un_proper_shipping_name: i[:un_proper_shipping_name],
        haz_class: Colin::Models::HazClass.where(id: i[:haz_class_ids]).to_a,
        haz_stat: Colin::Models::HazStat.where(id: i[:haz_stat_ids]).to_a,
        prec_stat: Colin::Models::PrecStat.where(id: i[:prec_stat_ids]).to_a,
        pictogram: Colin::Models::Pictogram.where(id: i[:pictogram_ids]).to_a,
        signal_word: Colin::Models::SignalWord.find_by(id: i[:signal_word_id])
      )
      return chemical.to_json(
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
      )
    else
      halt 422, "Chemical with given id not found"
    end

    
  end

  # Update a chemical by its id - At the moment this can only undelete a chemical.
  patch '/api/chemical/id/:id' do
    content_type :json
    unless session[:authorized] && current_user.can_edit_container?
      halt(401, 'Not authorised.')
    end

    if (chemical = Colin::Models::Chemical.with_deleted.find_by(id: params[:id]))
      chemical.restore
      chemical.to_json
    else
      halt 422, "Chemical with given id not found"
    end
  end

  # Deletes a chemcial by its id
  delete '/api/chemical/id/:id' do
    unless session[:authorized] && current_user.can_edit_container?
      halt(401, 'Not authorised.')
    end
    
    if (chemical = Colin::Models::Chemical.find_by(id: params[:id]))
      chemical.delete
      return 204
    else
      halt 422, "Chemical with given id not found"
    end
  end

  get '/api/chemical/search/cas/:cas' do
    content_type :json

    unless session[:authorized]
      halt(401, 'Not authorised.')
    end

    Colin::Models::Chemical.where("cas ILIKE ?", "%" + params[:cas] + "%").limit(params[:limit]).offset(params[:offset]).select(
      :id, :cas, :prefix, :name 
    ).to_json(
    )
  end

  get '/api/chemical/search/name/:name' do
    content_type :json

    unless session[:authorized]
      halt(401, 'Not authorised.')
    end

    Colin::Models::Chemical.where("CONCAT(prefix, name) ILIKE ?", "%" + params[:name] + "%").limit(params[:limit]).offset(params[:offset]).select(
      :id, :cas, :prefix, :name 
    ).to_json(
    )
  end


end
