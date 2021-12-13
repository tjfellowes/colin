class AddExtraSafetyInformation < ActiveRecord::Migration[5.2]
  def change
    create_table :signal_words do |t|
      t.string :name
    end

    create_table :haz_classes do |t|
      t.string :description
    end

    create_table :chemical_haz_classes do |t|
      t.references :chemical, index: true
      t.references :haz_class, index: true
      t.string :category
    end

    create_table :pictograms do |t|
      t.string :name
      t.binary :picture
    end

    create_table :chemical_pictograms do |t|
      t.references :chemical, index:true
      t.references :pictogram, index:true
    end

    create_table :haz_stats do |t|
      t.string :code
      t.string :description
    end

    create_table :chemical_haz_stats do |t|
      t.references :chemical, index: true
      t.references :haz_stat, index: true
    end

    create_table :prec_stats do |t|
      t.string :code
      t.string :description
    end

    create_table :chemical_prec_stats do |t|
      t.references :chemical, index: true
      t.references :prec_stat, index: true
    end

    add_column :chemicals, :storage_temperature_min, :string, null: true
    add_column :chemicals, :storage_temperature_max, :string, null: true
    add_column :chemicals, :un_proper_shipping_name, :string, null: true
    add_column :chemicals, :sds, :binary, null: true
    add_reference :chemicals, :signal_word, index: true
    add_column :chemicals, :inchi, :string, null: true
    add_column :chemicals, :smiles, :string, null: true
    add_column :chemicals, :pubchem, :string, null: true
    add_column :chemicals, :density, :float, null: true
    add_column :chemicals, :melting_point, :float, null: true
    add_column :chemicals, :boiling_point, :float, null: true

    rename_column :containers, :serial_number, :barcode
    change_column_null :containers, :barcode, true
    add_column :containers, :product_number, :string, null: true
    add_column :containers, :lot_number, :string, null: true
    add_reference :containers, :user, index: true
    add_reference :containers, :owner, foreign_key: { to_table: :users }
    add_column :containers, :picture, :binary, null: true

    add_column :suppliers, :website, :string, null: true

    change_column_null :locations, :code, true
    change_column_default :locations, :code, nil
  end
end
