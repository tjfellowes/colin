class Colin::Routes::User < Colin::BaseWebApp

    get "/api/user" do
        unless session[:authorized]
            halt(403, 'Not authorised.')
        end

        content_type :json

        Colin::Models::User.active.visible.limit(params[:limit]).offset(params[:offset]).select(:id, :name, :username).to_json()
    end
    
    post "/api/user" do 

        unless session[:authorized] && current_user.can_create_user?
            halt(403, 'Not authorised.')
        end
        
        content_type :json

        if params[:username].blank? || params[:email].blank? || params[:password].blank? || params[:name].blank? 
            halt(422, 'Username, name, email, and password are required.')
        elsif params[:password] != params[:password_confirmation]
            halt(422, 'Passwords do not match.')
        elsif Colin::Models::User.exists?(username: params[:username])
            halt(422, 'User ' +  params[:username] + ' already exists.')
        else
            if params[:supervisor_id].blank?
                params[:supervisor_id] = 1
            end
            Colin::Models::User.create(username: params[:username], name: params[:name], email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation], supervisor_id: params[:supervisor_id], can_create_container: params[:can_create_container], can_edit_container: params[:can_edit_container], can_create_location: params[:can_create_location], can_edit_location: params[:can_edit_location], can_create_user: params[:can_create_user], can_edit_user: params[:can_edit_user]).to_json()
        end
    end 

    put "/api/user/username/:username" do 
        unless session[:authorized] && ( current_user.can_edit_user? || current_user.username == params[:username] )
            halt(403, 'Not authorised to edit this user.')
        end

        content_type :json

        if params[:username].blank? 
            halt(422, "Username not supplied.")
        elsif Colin::Models::User.where(username: params[:username]).exists?
            user = Colin::Models::User.where(username: params[:username]).take
            unless params[:password].blank? 
                if user.authenticate(params[:old_password]) || current_user.can_edit_user
                    if params[:password] == params[:password_confirmation]
                        user.update(password: params[:password], password_confirmation: params[:password_confirmation])
                    else
                        halt(422, "Passwords do not match.")
                    end
                else
                    halt(422, "Old password incorrect.")
                end
            end
            if !params[:new_username].blank?
                if (params[:new_username] != user.username) 
                    if Colin::Models::User.exists?(username: params[:new_username])
                        halt(422, 'User ' +  params[:new_username] + ' already exists.')
                    else
                        user.update(username: params[:new_username])
                    end
                end
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

            if current_user.can_edit_user
                user.update(can_create_container: params[:can_create_container], can_edit_container: params[:can_edit_container], can_create_location: params[:can_create_location], can_edit_location: params[:can_edit_location], can_create_user: params[:can_create_user], can_edit_user: params[:can_edit_user])
            end

            user.update(date_deleted: nil)

            user.to_json()
        else
            halt(404, "Username with username " + params[:username] + " not found.")
        end
    end 
    delete "/api/user/username/:username" do 
        unless session[:authorized] && current_user.can_edit_user?
            halt(403, 'Not authorised to delete this user.')
        end

        if params[:username].blank? 
            halt(422, "Username not supplied.")
        elsif Colin::Models::User.where(username: params[:username]).exists?
            Colin::Models::User.where(username: params[:username]).take.update(date_deleted: Time.now).to_json()
        else
            halt(404, "Username with username " + params[:username] + " not found.")
        end
    end
end