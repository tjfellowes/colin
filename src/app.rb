require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/cross_origin'
require 'json'
require 'securerandom'
require 'bcrypt'

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
    end

    # Make every request JSON
    before do
      content_type :json
    end

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

    enable :sessions
    set :session_store, Rack::Session::Pool
    set :sessions, :expire_after => 2592000

    # Single-page front-end web app
    get '/' do
      redirect '/index.html'
    end

    get '' do
      redirect '/index.html'
    end

    post '/newaccount' do
      user = Colin::Models::User.new(username: params[:username])
      user.password = params[:password]
      user.save!
    end

    post '/login' do
      user = Colin::Models::User.find(username: params[:username])
      if user.password == params[:password]
        session[:authorized] = true
      end
      redirect '/index.html'
    end

    # Route for 404 not found
    #not_found do
    #  redirect '/404.html'
    #end
  end
end
