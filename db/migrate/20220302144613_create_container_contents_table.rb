class CreateContainerContentsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :container_contents do |t|
      t.references :container, index: true
      t.references :chemical, index: true
      t.float :quantity
      t.string :quantity_unit
      t.float :concentration
      t.string :concentration_unit
    end
  end
end
