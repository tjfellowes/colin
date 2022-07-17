class Colin::Routes::User < Colin::BaseWebApp

    get "/api/user" do
        unless session[:authorized]
            halt(401, 'Not authorised.')
        end

        content_type :json

        Colin::Models::User.visible.limit(params[:limit]).offset(params[:offset]).select(:id, :name, :username).to_json()
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

    put "/api/user/id/:id" do 
        unless session[:authorized] && ( current_user.can_edit_user? || current_user.id == params[:id] )
            halt(401, 'Not authorised to edit this user.')
        end

        content_type :json

        payload = JSON.parse(request.body.read, symbolize_names: true)


        if user = Colin::Models::User.find_by(id: params[:id])
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
        else
            halt(404, "User with id " + params[:id] + " not found.")
        end
    end 

      # Update a location by its id - At the moment this can only undelete a location.
    patch '/api/user/id/:id' do
        content_type :json
        unless session[:authorized] && current_user.can_edit_user?
            halt(401, 'Not authorised.')
        end

        if (user = Colin::Models::User.with_deleted.find_by(id: params[:id]))
            user.restore
            user.to_json(
                include: :supervisor
            )
        else
            halt 422, "User with given id not found"
        end
    end

    delete "/api/user/id/:id" do 
        unless session[:authorized] && current_user.can_edit_user?
            halt(403, 'Not authorised to delete this user.')
        end

        if params[:id].blank? 
            halt(422, "id not supplied.")
        elsif user = Colin::Models::User.find_by(id: params[:id])
            user.delete
            status 204
        else
            halt(404, "User with id " + params[:id] + " not found.")
        end
    end
end