class CreateContainerContentsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :container_contents do |t|
      t.references :container, index: true, null: false
      t.references :chemical, index: true, null: false
      t.float :quantity_number
      t.string :quantity_unit
      t.float :concentration_number
      t.string :concentration_unit
    end
  end
end
