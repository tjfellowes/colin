require 'sinatra/base'
require 'time'

#
# Routes for Chemical model
#
class Colin::Routes::Chemical < Sinatra::Base
  #
  # Gets all chemicals. Pagination supported using the `limit' and `offset'
  # query parameters. E.g. GET /chemical?limit=1&offset=15 gets the first page
  # of 15 chemicals. Defaults are page 1 and size 15. 
  #
  get '/api/chemical/all' do
    content_type :json

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    Colin::Models::Chemical.limit(params[:limit]).offset(params[:offset]).to_json(include: {
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
    })
  end

  post '/api/chemical' do
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
  end

  get '/api/chemical/cas/:cas' do
    content_type :json

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end

    # Must provide a CAS number. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.
    if params[:cas].nil?
      halt(422, 'Must provide a CAS number for chemical.')
    elsif Colin::Models::Chemical.exists?(:cas => params[:cas])
      Colin::Models::Chemical.where(cas: params[:cas]).to_json(include: {
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
      })
    else
      halt(404, "Chemical with CAS #{params[:cas]} not found.")
    end
  end

  # get '/api/create/chemical/' do
  #   Colin::Models::Chemical.create(cas: params[:cas], prefix: params[:prefix], name: params[:name], haz_substance: params[:haz_substance], un_number: params[:un_number], dg_class_id: params[:dg_class_id], dg_class_2_id: params[:dg_class_2_id], dg_class_3_id: params[:dg_class_3_id], schedule_id: params[:schedule_id], packing_group_id: params[:packing_group_id], created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601).to_json()
  #   # Colin::Models::Chemical.find(params[:id]).to_json(include: [
  #   #     :dg_class,
  #   #     :dg_subclass,
  #   #     :schedule,
  #   #     :packing_group
  #   #   ])
  #   #redirect '/'
  # end

end
