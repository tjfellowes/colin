class CreateContainerChemicalTable < ActiveRecord::Migration[5.2]
  def change
    create_table :container_chemicals do |t|
      t.references :container, index: true
      t.references :chemical, index: true
      t.float :quantity
      t.string :quantity_unit
    end
  end
end
