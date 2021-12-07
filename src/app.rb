require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/cross_origin'
require 'json'
require 'securerandom'
require 'bcrypt'
require 'rack-flash'
require "open-uri"

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
      Colin::Routes::Location
    ]
  end

  # Expose the run function as a module-level function for CoLIN (i.e., to
  # call Colin.run).
  module_function :run

  #
  # The primary web application, CoLIN.
  #
  class BaseWebApp < Sinatra::Base
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

    get '/' do
      if logged_in?
        erb :"index.html"
      else
        erb :login
      end
    end

    get '' do
      redirect '/'
    end

    helpers do
     
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
        Colin::Models::Container.joins('LEFT JOIN container_locations i ON i.container_id = containers.id AND i.id = (SELECT MAX(id) FROM container_locations WHERE container_locations.container_id = i.container_id) INNER JOIN chemicals ON containers.chemical_id = chemicals.id').where("CONCAT(chemicals.prefix, chemicals.name) ILIKE :query OR barcode LIKE :query OR chemicals.cas LIKE :query", { query: "%"+query+"%"})
      end
    
    end
    # Route for 404 not found
    #not_found do
    #  redirect '/404.html'
    #end
  end
end
