require 'sinatra/base'
require 'time'

#
# Routes for Chemical model
#
class Colin::Routes::Chemical < Sinatra::Base
  #
  # Gets all chemicals. Pagination supported using the `page' and `size'
  # query parameters. E.g. GET /chemical?page=1&size=15 gets the first page
  # of 15 chemicals. Defaults are page 1 and size 15. To return all chemicals,
  # provide 0 to both query parameters.
  #
  get '/api/chemical/all' do
    # Get the parameters out, and default them to 1 and 15, respectively.
    # Fetch allows you to get a key and default it if it does not exist.
    page_start = params.fetch(:page, 1)
    page_size  = params.fetch(:size, 15)
    if page_size.zero? && page_start.zero?
      # Where 0 has been provided for both, use `Chemical.all'
      Colin::Models::Chemical.all
    else
      # Where a specified page size and page start have been provided, use
      # the limit and offset functions. See http://guides.rubyonrails.org/active_record_querying.html#limit-and-offset
      Colin::Models::Chemical.limit(page_size).offset(page_start)
    end
  end

  #
  # Gets the specified chemical with the given ID.
  #


  get '/api/chemical/:cas' do
    # Must provide a CAS number. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.
    if params[:cas].nil?
      halt(422, 'Must provide a CAS number for chemical.')
    elsif Colin::Models::Chemical.exists?(:cas => params[:cas])
      Colin::Models::Chemical.where(cas: params[:cas]).to_json(include: {
        schedule: {},
        packing_group: {},
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

  get '/api/chemical/find_by_id/:id' do
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.
    if params[:id].nil?
      halt(422, 'Must provide an numerical ID for chemical.')
    elsif Colin::Models::Chemical.exists?(params[:id])
      Colin::Models::Chemical.find(params[:id]).to_json(include: {
        schedule: {},
        packing_group: {},
        dg_class: { include: :superclass },
        dg_class_2: { include: :superclass },
        dg_class_3: { include: :superclass }
      })
    else
      halt(404, "Chemical with id #{params[:id]} not found.")
    end
  end

  get '/api/chemical/search/:query' do
    content_type :json
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.
    Colin::Models::Chemical.where("name_fulltext LIKE :query OR cas LIKE :query", { query: "%#{params[:query]}%"}).includes(
      schedule: {},
      packing_group: {},
      dg_class:  :superclass,
      dg_class_2: :superclass,
      dg_class_3: :superclass
    ).to_json(include: {
      schedule: {},
      packing_group: {},
      dg_class: {include: :superclass},
      dg_class_2: {include: :superclass},
      dg_class_3: {include: :superclass}
    })
  end
end
