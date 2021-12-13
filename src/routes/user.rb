class Colin::Routes::User < Colin::BaseWebApp
    get "/user" do 
        if logged_in?
            @user = current_user
            erb :"index.html"
        else
            redirect to '/login'
        end
    end

    get '/user/new' do 
        erb :"/users/new.html"
    end 
    
    post "/api/user" do 
        if params[:username].empty? || params[:email].empty? || params[:password].empty? || params[:name].empty? 
            flash.now[:message] = "You must complete all fields in order to create an account. Please try again."
            redirect to '/user/new'
        else
            @user = Colin::Models::User.create(username: params[:username], name: params[:name], email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation], supervisor_id: params[:supervisor_id])
            session[:user_id] = @user.id 
            flash.now[:message] = "Account has been succesfully created!"
            redirect to '/'
        end
    end 
end