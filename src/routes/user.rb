class Colin::Routes::User < Colin::BaseWebApp
    get "/user" do 
        if logged_in?
            @user = current_user
            erb :"users/index.html"
        else
            redirect to '/login'
        end
    end

    get '/newuser' do 
        erb :"/users/new.html"
    end 
    
    post "/newuser" do 
        if params[:username].empty? || params[:email].empty? || params[:password].empty? || params[:name].empty? 
            flash[:message] = "You must complete all fields in order to create an account. Please try again."
            redirect to '/newuser'
        else
            @user = Colin::Models::User.create(username: params[:username], name: params[:name], email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation])
            session[:user_id] = @user.id 
            flash[:message] = "Your account has been succesfully created!"
            erb :"/users/index.html"
        end
    end 
end