class AddPermissions < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :can_create_container, :boolean, default: false
    add_column :users, :can_edit_container, :boolean, default: false
    add_column :users, :can_create_location, :boolean, default: false
    add_column :users, :can_edit_location, :boolean, default: false
    add_column :users, :can_create_user, :boolean, default: false
    add_column :users, :can_edit_user, :boolean, default: false
    remove_column :users, :issuperuser
    remove_column :users, :isadmin
  end
end
