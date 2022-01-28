require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/cross_origin'
require 'json'
require 'securerandom'
require 'bcrypt'
require 'rack-flash'
require 'open-uri'
require 'pagy'
require 'pagy/extras/bootstrap'

#
# CoLIN, the COmprehensive Labortory Information Nexus.
# The base module for CoLIN includes all routes (endpoints)
# and Models (data ORM).
#
module Colin
  #
  # Module that defines all routes (endpoints) under CoLIN. These are added
  # under the `routes' directory.
  #
  module Routes; end

  #
  # Module that defines all models (ORM) under CoLIN. These are added under
  # the `models' directory.
  #
  module Models; end

  #
  # Runs CoLIN by importing all required routes, modules and Sinatra.
  #
  def run
    # Require everything inside `src'.
    require 'require_all'
    require_all 'src'
    # Create a new CoLIN application with all routes here.
    Rack::Cascade.new [
      Colin::BaseWebApp,
      Colin::Routes::User,
      Colin::Routes::Session,
      Colin::Routes::Chemical,
      Colin::Routes::Container,
      Colin::Routes::Location,
      Colin::Routes::LocationType
    ]
  end

  # Expose the run function as a module-level function for CoLIN (i.e., to
  # call Colin.run).
  module_function :run

  #
  # The primary web application, CoLIN.
  #
  class BaseWebApp < Sinatra::Base

    include Pagy::Backend  
    
    # Configuration settings
    configure do
      enable :cross_origin
      # Enable logging
      enable :logging
      # Set the public folder to 'public'
      set :public_folder, 'public'
      # Enable ActiveRecord extension
      register Sinatra::ActiveRecordExtension

      set :sessions, true
        set :session_secret, ENV['SESSION_SECRET']

      use Rack::Flash
    end

    # Make every request JSON
    #before do
    #  content_type :json
    #end

    # Development-specific configuration settings
    # configure :development do
    #   # Test database
    #   set :database, adapter: 'postgresql', database: 'colin_development', pool: '5', timeout: '5000'
    # end

    # configure :test do
    #   set :database, adapter: 'postgresql', database: 'colin_test', pool: '5', timeout: '5000'
    # end

    # configure :production do
    #   set :database, adapter: 'postgresql', database: 'colin_production', pool: '5', timeout: '5000'
    # end

    set :environment, :development

    before "/user/*" do
      puts(request.host)
      https_required!
    end

    get '/' do
      if logged_in?
        erb :"index.html"
      else
        redirect to '/user/login'
      end
    end

    get '' do
      redirect '/'
    end

    get '/container/search' do
      if params[:query].blank?
        flash[:message] = "Please supply a search query."
        redirect to ''
      else
        erb :'containers/search.html'
      end
    end
  
    get '/container/new' do
      erb :'containers/new.html'
    end
  
    get '/container/barcode/:barcode' do
      erb :'containers/detail.html'
    end
  
    get '/container/edit/barcode/:barcode' do
      erb :'containers/edit.html'
    end
    
    get '/chemical/edit/cas/:cas' do
      erb :'chemicals/edit.html'
    end
    
    get '/location/new' do
      erb :'locations/new.html'
    end 

    get '/location/stocktake/:location_id' do
      erb :'locations/stocktake.html'
    end

    get '/user/login' do 
      erb :"/login"
    end 

    get '/user/new' do 
      erb :"/users/new.html"
    end 

    get '/user/edit' do 
      erb :"/users/edit.html"
    end 

    get '/img/favicon.ico' do
      'blep'
    end
  

    helpers do
      
      include Pagy::Frontend

      def https_required!
        #if settings.production? && request.scheme == 'http'
        if request.scheme == 'http' && request.host != 'localhost' 
            headers['Location'] = request.url.sub('http', 'https')
            halt 301, "https required\n"
        end
      end
     
      def logged_in?
        !!session[:user_id]
      end
  
      def current_user 
        Colin::Models::User.find_by(:id => session[:user_id]) 
      end 
  
      def redirect_if_not_logged_in 
        if !logged_in? 
          redirect to '/login' 
        end  
      end   

      def search_containers(query)
        
      end
    
    end

    # Route for 404 not found
    #not_found do
    #  redirect '/404.html'
    #end
  end
end
