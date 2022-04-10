class AddContainerSafetyData < ActiveRecord::Migration[5.2]
  def change
    add_column :containers, :prefix, :string
    add_column :containers, :name, :string
    add_column :containers, :haz_substance, :boolean
    add_reference :containers, :dg_class_1, references: :dg_classes
    add_reference :containers, :dg_class_2, references: :dg_classes
    add_reference :containers, :dg_class_3, references: :dg_classes
    add_reference :containers, :packing_group
    add_column :containers, :un_number, :string
    add_column :containers, :un_proper_shipping_name, :string
    add_reference :containers, :schedule
    add_reference :containers, :signal_word
    add_column :containers, :storage_temperature_min, :string
    add_column :containers, :storage_temperature_max, :string
    add_column :containers, :density, :string
    add_column :containers, :melting_point, :string
    add_column :containers, :boiling_point, :string
    add_column :containers, :sds, :binary

    create_join_table :containers, :haz_classes do |t|
      t.index :container_id
      t.index :haz_class_id
    end

    create_join_table :containers, :pictograms do |t|
      t.index :container_id
      t.index :pictogram_id
    end

    create_join_table :containers, :haz_stats do |t|
      t.index :container_id
      t.index :haz_stat_id
    end

    create_join_table :containers, :prec_stats do |t|
      t.index :container_id
      t.index :prec_stat_id
    end
  end
end
