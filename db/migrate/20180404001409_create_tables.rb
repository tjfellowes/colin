class CreateTables < ActiveRecord::Migration[5.1]
  def change
    # Create dependent tables dg_classes, schedules and packing groups
    # The tables must be PLURALIZED... see https://en.wikibooks.org/wiki/Ruby_on_Rails/ActiveRecord/Naming#Tables
    create_table :dg_classes do |t|
      t.text     :number,      null: false
      t.text        :description, null: false
      t.references  :superclass,  references: :dg_classes
    end

    create_table :schedules do |t|
      t.integer :number,    null: false
      t.text :description,  null: true
    end

    create_table :packing_groups do |t|
      t.string :name, null: false
    end

    create_table :chemicals do |t|
      # Basic fields
      t.string  :cas,           null: false
      t.string  :prefix,        null: true
      t.string  :name,          null: false
      t.boolean :haz_substance, null: false
      t.string  :sds_url,       null: true
      t.string  :un_number,     null: true

      # Foreign keys with indexing enabled
      t.references :dg_class_1,       index: true, null: true
      t.references :dg_class_2,     references: :dg_classes, index: true, null: true
      t.references :dg_class_3,     references: :dg_classes, index: true, null: true
      t.references :schedule,       index: true, null: true
      t.references :packing_group,  index: true, null: true

      # Adds created_at and updated_at fields.
      t.timestamps
    end

    create_table :containers do |t|
      # Basic Fields
      t.string :serial_number,    null: false
      t.float :container_size,    null: true
      t.string :size_unit,        null: true
      t.datetime :date_purchased, null: false
      t.datetime :expiry_date,    null: true
      t.datetime :date_disposed,  null: true

      # Foreign keys
      t.references :chemical,  index: true, null: false
      t.references :supplier,  index: true, null: true
    end

    create_table :suppliers do |t|
      t.string :name, null: false
    end

    create_table :container_locations do |t|
      t.timestamps
      t.references :container,     index: true, null: false
      t.references :location,      index: true, null: true
    end

    create_table :locations do |t|
      t.string :name, null: false
      t.references :parent, references: :locations
    end
  end
end
