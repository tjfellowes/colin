class AddViewUserColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :can_view_user, :boolean, default: false
  end
end
