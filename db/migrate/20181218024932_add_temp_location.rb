class AddTempLocation < ActiveRecord::Migration[5.1]
  def change
    add_column :container_locations, :temp, :boolean, null: false, default: false
  end
end
