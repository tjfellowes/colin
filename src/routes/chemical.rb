require 'sinatra/base'

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
  get '/api/chemical' do
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
  get '/api/chemical/:id' do
    # Must provide an integer ID. Otherwise respond with 422 (https://restpatterns.mindtouch.us/HTTP_Status_Codes/422_-_Unprocessable_Entity)
    # which means invalid data provided from user.
    if params[:id].nil?
      halt(422, 'Must provide an numerical ID for chemical.')
    elsif Colin::Models::Chemical.exists?(params[:id])
      Colin::Models::Chemical.find(params[:id]).to_json
    else
      halt(404, "Chemical with id #{params[:id]} not found.")
    end
  end

  post '/api/chemical/:id' do
  end
end
