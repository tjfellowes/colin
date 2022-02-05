class AddUserLocationDateDeleted < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :date_deleted, :datetime, null: true
    add_column :locations, :date_deleted, :datetime, null: true
    add_column :suppliers, :date_deleted, :datetime, null: true
  end
end
