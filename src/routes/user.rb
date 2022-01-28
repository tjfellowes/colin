class Colin::Routes::User < Colin::BaseWebApp
    
    post "/api/user" do 
        if params[:username].blank? || params[:email].blank? || params[:password].blank? || params[:name].blank? 
            flash.now[:message] = "You must complete all fields in order to create an account. Please try again."
            redirect to '/user/new'
        else
            user = Colin::Models::User.create(username: params[:username], name: params[:name], email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation], supervisor_id: params[:supervisor_id], isadmin: params[:isadmin])
            session[:user_id] = user.id 
            flash.now[:message] = "Account has been succesfully created!"
            redirect to '/'
        end
    end 

    post "/api/user/edit/username/:username" do 
        if params[:username].blank? 
            halt(422, "Username not supplied.")
        elsif params[:username] != current_user.username && !current_user.issuperuser
            halt(403, "Cannot edit other users!")
        elsif Colin::Models::User.where(username: params[:username]).exists?
            user = Colin::Models::User.where(username: params[:username]).take
            if !params[:password].blank? 
                if user.authenticate(params[:old_password]) || current_user.issuperuser
                    if params[:password] == params[:password_confirmation]
                        user.update(password: params[:password], password_confirmation: params[:password_confirmation])
                    else
                        halt(403, "Passwords do not match.")
                    end
                else
                    halt(403, "Old password incorrect.")
                end
            end
            if !params[:new_username].blank?
                user.update(username: params[:username])
            end
            if !params[:name].blank?
                user.update(name: params[:name])
            end
            if !params[:email].blank?
                user.update(email: params[:email])
            end
            if !params[:supervisor_id].blank?
                user.update(supervisor_id: params[:supervisor_id])
            end
            flash.now[:message] = "Account updated!"
            redirect to '/'
        else
            halt(422, "Username with username " + params[:username] + " not found.")
        end
    end 
end