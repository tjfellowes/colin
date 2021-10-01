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

    Colin::Models::Chemical.limit(params[:limit]).offset(params[:offset]).to_json()
  end

  post '/api/chemical' do

    unless session[:authorized]
      halt(403, 'Not authorised.')
    end
    
    Colin::Models::Chemical.create_chemical(params)
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
end
