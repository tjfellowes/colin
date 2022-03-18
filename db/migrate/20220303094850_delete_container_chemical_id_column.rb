class DeleteContainerChemicalIdColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :containers, :chemical_id
  end
end
