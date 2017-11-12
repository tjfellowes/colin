class CreateChemicals < ActiveRecord::Migration[5.1]
  def change
    # Create dependent tables dg_classes, schedules and packing groups
    # The tables must be PLURALIZED... see https://en.wikibooks.org/wiki/Ruby_on_Rails/ActiveRecord/Naming#Tables
    create_table :dg_classes do |t|
      t.integer     :number,      null: false
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
      t.string  :serial_number, null: false
      t.string  :cas,           null: false
      t.string  :prefix,        null: false
      t.string  :name,          null: false
      t.boolean :haz_substance, null: false
      t.string  :sds_url,       null: false
      t.string  :un_number

      # Foreign keys with indexing enabled
      t.belongs_to :dg_class,       index: true
      t.belongs_to :schedule,       index: true
      t.belongs_to :packing_group,  index: true
      t.references :subrisk, :dg_classes

      # Adds created_at and updated_at fields.
      t.timestamps
    end
  end
end
