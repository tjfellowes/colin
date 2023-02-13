#
# CoLIN, the COmprehensive Labortory Information Nexus.
#
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
require 'paranoia'
#
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
      Colin::Routes::LocationType,
      Colin::Routes::Pictogram,
      Colin::Routes::HazClass,
      Colin::Routes::DgClass,
      Colin::Routes::HazStat,
      Colin::Routes::PrecStat,
      Colin::Routes::Schedule,
      Colin::Routes::PackingGroup,
      Colin::Routes::Supplier,
      Colin::Routes::SignalWord
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

      set :server_settings, :Verbose => true

      use Rack::Flash
      use Rack::Protection::EncryptedCookie,
        key: 'rack.session',
        secret: ENV['SESSION_SECRET']
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
        flash[:message] = 'Please supply a search query.'
        redirect to ''
      else
        erb :'containers/list.html'
      end
    end

    get '/container' do
      params[:query] = '%'
      erb :'containers/list.html'
    end

    get '/container/new' do
      if current_user.can_create_container?
        erb :'containers/new.html'
      else
        halt(403, 'Not authorised!')
      end
    end

    get '/container/barcode/:barcode' do
      erb :'containers/detail.html'
    end

    get '/container/edit/barcode/:barcode' do
      if current_user.can_edit_container?
        erb :'containers/edit.html'
      else
        halt(403, 'Not authorised!')
      end
    end

    get '/chemical/edit/cas/:cas' do
      if current_user.can_edit_container?
        erb :'chemicals/edit.html'
      else
        halt(403, 'Not authorised!')
      end
    end

    get '/location' do
      if current_user.can_edit_location?
        erb :'locations/list.html'
      else
        halt(403, 'Not authorised!')
      end
    end 

    get '/location/new' do 
      if current_user.can_create_location?
        erb :"/locations/new.html"
      else
        halt(403, 'Not authorised!')
      end
    end 

    get '/location/edit/:location_id' do 
      if current_user.can_edit_location?
        erb :"/locations/edit.html"
      else
        halt(403, 'Not authorised!')
      end
    end 

    get '/location/stocktake' do
      erb :'locations/stocktake.html'
    end

    get '/user' do
      if current_user.can_edit_user?
        erb :'users/list.html'
      else
        halt(403, 'Not authorised!')
      end
    end 

    get '/user/login' do 
      erb :"/login"
    end 

    get '/user/new' do 
      if current_user.can_create_user?
        erb :"/users/new.html"
      else
        halt(403, 'Not authorised!')
      end
    end 

    get '/user/username/edit/:username' do 
      if current_user.can_edit_user? || current_user.username == params[:username]
        erb :"/users/edit.html"
      else
        halt(403, 'Not authorised!')
      end
    end 

    get '/waste/special' do
      erb :"/waste/new.html"
    end

    get '/waste/special/label' do
      erb :"/waste/special_waste_label.html", layout: false
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
        Colin::Models::User.find_by(id: session[:user_id])
      end

      def redirect_if_not_logged_in
        unless logged_in? 
          redirect to '/login'
        end
      end

    end

    # Route for 404 not found
    #not_found do
    #  #bum
    #end
  end
end
