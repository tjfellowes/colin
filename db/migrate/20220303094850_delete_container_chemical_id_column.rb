class DeleteContainerChemicalIdColumn < ActiveRecord::Migration[5.2]
  def change
    remove_reference :containers, :chemical, index: true
  end
end
