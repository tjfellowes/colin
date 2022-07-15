class Colin::Routes::Session < Colin::BaseWebApp

    get "/user/login" do 
      if logged_in?
        redirect to "/"
      else
        erb :login 
      end 
    end 

    post '/api/user/login' do
      content_type :json
      user = Colin::Models::User.find_by(username: params[:username])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        session[:authorized] = true
        return 200, 'User sucessfully authenticated'
      elsif params[:username].empty? || params[:password].empty? 
        halt 401, 'Username or password cannot be empty'
      else 
        halt 401, 'Incorrect username or password'
      end
    end
      
    post '/user/login' do
      user = Colin::Models::User.find_by(username: params[:username])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        session[:authorized] = true
        redirect to '/' 
      elsif params[:username].empty? || params[:password].empty? 
          flash.now[:message] = "Username or password cannot be blank. please try again."
          content_type :html
          erb :login 
      else 
        flash.now[:message] = "Incorrect username or password. Please try again."
        content_type :html
        erb :login
      end
    end
    
    get '/user/logout' do 
      session.destroy
      redirect to '/'
    end 
    
  end