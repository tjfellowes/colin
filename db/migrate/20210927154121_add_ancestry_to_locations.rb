class AddAncestryToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :ancestry, :string, index: true
    remove_column :locations, :parent_id
  end
end
