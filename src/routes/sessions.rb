class Colin::Routes::Session < Colin::BaseWebApp

    get "/login" do 
      if logged_in?
        redirect to "/user"
      else
        erb :login 
      end 
    end 
      
    post '/login' do
      user = Colin::Models::User.find_by(username: params[:username])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        session[:authorized] = true
        redirect to '/user' 
      elsif params[:username].empty? || params[:password].empty? 
          flash[:message] = "Username or password cannot be blank. please try again."
          content_type :html
          erb :login 
      else 
        flash[:message] = "Incorrect username or password. Please try again."
        content_type :html
        erb :login
      end
    end
    
    get '/logout' do 
      session.destroy
      redirect to '/'
    end 
    
  end