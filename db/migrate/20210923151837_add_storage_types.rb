class AddStorageTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :location_types do |t|
      t.text  :name, null: false
    end

    create_table :standards do |t|
      t.text  :name, null: false
      t.text  :description, null:false
    end

    create_table :location_standards do |t|
      t.references  :locations, index: true
      t.references  :standards, index: true
    end 

    add_column :locations, :barcode, :string, null: true
    add_reference :locations, :location_types
    add_column :locations, :temperature, :string, null: true
    add_column :locations, :monitored, :boolean, null: false, default: false
  end
end
