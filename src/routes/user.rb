class Colin::Routes::User < Colin::BaseWebApp

    get "/api/user" do
        unless session[:authorized]
            halt(401, 'Not authorised.')
        end
        content_type :json
        
        unless (body = request.body.read).blank?
            payload = JSON.parse(body, symbolize_names: true)
            if (current_user.id == payload[0][:id]) || (current_user.id == 1)
                Colin::Models::User.find(payload[0][:id]).to_json(include: :supervisor)
            end
        else
            Colin::Models::User.visible.limit(params[:limit]).offset(params[:offset]).select(:id, :name, :username).to_json()
        end
    end
    
    post "/api/user" do 

        unless session[:authorized] && current_user.can_create_user?
            halt(401, 'Not authorised.')
        end
        
        content_type :json

        payload = JSON.parse(request.body.read, symbolize_names: true)

        users = []

        for i in payload
            if i[:username].blank? || i[:email].blank? || i[:password].blank? || i[:name].blank? 
                halt(422, 'Username, name, email, and password are required.')
            elsif i[:password] != i[:password_confirmation]
                halt(422, 'Passwords do not match.')
            elsif Colin::Models::User.exists?(username: i[:username])
                halt(422, 'User ' +  i[:username] + ' already exists.')
            else
                if i[:supervisor_id].blank?
                    i[:supervisor_id] = 1
                end
                users.append(Colin::Models::User.new(
                    username: i[:username], 
                    name: i[:name], 
                    email: i[:email], 
                    password: i[:password], 
                    password_confirmation: i[:password_confirmation], 
                    supervisor_id: i[:supervisor_id], 
                    can_create_container: i[:can_create_container], 
                    can_edit_container: i[:can_edit_container], 
                    can_create_location: i[:can_create_location], 
                    can_edit_location: i[:can_edit_location], 
                    can_create_user: i[:can_create_user], 
                    can_edit_user: i[:can_edit_user]
                ))
            end
        end
        
        if !users.map{|i| i.save}.include?(false)
            return users.to_json(
                include: {
                    supervisor: {}
                }
            )
        else
            halt 500, "Could not save users to the database"
        end
    end 

    put "/api/user" do 
        unless session[:authorized] && ( current_user.can_edit_user? || current_user.id == i[:id] )
            halt(401, 'Not authorised to edit this user.')
        end

        content_type :json

        payload = JSON.parse(request.body.read, symbolize_names: true)

        users = []

        for i in payload
            if user = Colin::Models::User.find_by(id: i[:id])
                users.append(
                    if i[:old_password].blank? && i[:password].blank? && i[:password_confirmation].blank?
                        user.update(
                            username: i[:username], 
                            name: i[:name], 
                            email: i[:email], 
                            supervisor_id: i[:supervisor_id], 
                            can_create_container: i[:can_create_container], 
                            can_edit_container: i[:can_edit_container], 
                            can_create_location: i[:can_create_location], 
                            can_edit_location: i[:can_edit_location], 
                            can_create_user: i[:can_create_user], 
                            can_edit_user: i[:can_edit_user]
                        )
                    elsif user.authenticate(i[:old_password])
                        if i[:password].blank? || i[:password_confirmation].blank?
                            halt(422, "New password cannot be blank.")
                        elsif i[:password] != i[:password_confirmation]
                            halt(422, 'Passwords do not match.')
                        else
                            user.update(
                                username: i[:username], 
                                name: i[:name], 
                                email: i[:email], 
                                password: i[:password],
                                password_confirmation: i[:password_confirmation],
                                supervisor_id: i[:supervisor_id], 
                                can_create_container: i[:can_create_container], 
                                can_edit_container: i[:can_edit_container], 
                                can_create_location: i[:can_create_location], 
                                can_edit_location: i[:can_edit_location], 
                                can_create_user: i[:can_create_user], 
                                can_edit_user: i[:can_edit_user]
                            )
                        end
                    else
                        halt(422, "Old password incorrect.")
                    end
                )
            else
                halt(404, "User with id " + i[:id] + " not found.")
            end
        end
        return users.to_json(
            include: :supervisor
        )
    end 

      # Update a location by its id - At the moment this can only undelete a location.
    patch '/api/user' do
        content_type :json
        unless session[:authorized] && current_user.can_edit_user?
            halt(401, 'Not authorised.')
        end

        content_type :json

        payload = JSON.parse(request.body.read, symbolize_names: true)

        users = []
        for i in payload
            if (user = Colin::Models::User.with_deleted.find_by(id: i[:id]))
                user.restore
                users.append(user)
            else
                halt 422,"User with given id not found"
            end
        end
        return users.to_json(
            include: :supervisor
        )
    end

    delete "/api/user" do 
        unless session[:authorized] && current_user.can_edit_user?
            halt(403, 'Not authorised to delete this user.')
        end

        content_type :json

        payload = JSON.parse(request.body.read, symbolize_names: true)

        for i in payload
            if i[:id].blank? 
                halt(422, "id not supplied.")
            elsif user = Colin::Models::User.find_by(id: i[:id])
                user.delete
                status 204
            else
                halt(404, "User with id " + i[:id] + " not found.")
            end
        end
    end
end