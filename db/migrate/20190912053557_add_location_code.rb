class AddLocationCode < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :code, :string, null: false, default: ''
  end
end
