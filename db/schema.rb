# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190827045318) do

  create_table "chemicals", force: :cascade do |t|
    t.string "cas", null: false
    t.string "prefix"
    t.string "name", null: false
    t.boolean "haz_substance", null: false
    t.string "sds_url"
    t.string "un_number"
    t.integer "dg_class_id"
    t.integer "dg_class_2_id"
    t.integer "dg_class_3_id"
    t.integer "schedule_id"
    t.integer "packing_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_fulltext", default: "", null: false
    t.index ["dg_class_2_id"], name: "index_chemicals_on_dg_class_2_id"
    t.index ["dg_class_3_id"], name: "index_chemicals_on_dg_class_3_id"
    t.index ["dg_class_id"], name: "index_chemicals_on_dg_class_id"
    t.index ["packing_group_id"], name: "index_chemicals_on_packing_group_id"
    t.index ["schedule_id"], name: "index_chemicals_on_schedule_id"
  end

  create_table "container_locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "container_id", null: false
    t.integer "location_id"
    t.boolean "temp", default: false, null: false
    t.index ["container_id"], name: "index_container_locations_on_container_id"
    t.index ["location_id"], name: "index_container_locations_on_location_id"
  end

  create_table "containers", force: :cascade do |t|
    t.string "serial_number", null: false
    t.float "container_size"
    t.string "size_unit"
    t.datetime "date_purchased", null: false
    t.datetime "expiry_date"
    t.datetime "date_disposed"
    t.integer "chemical_id", null: false
    t.integer "supplier_id"
    t.index ["chemical_id"], name: "index_containers_on_chemical_id"
    t.index ["supplier_id"], name: "index_containers_on_supplier_id"
  end

  create_table "dg_classes", force: :cascade do |t|
    t.text "number", null: false
    t.text "description", null: false
    t.integer "superclass_id"
    t.index ["superclass_id"], name: "index_dg_classes_on_superclass_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.string "name_fulltext", default: "", null: false
    t.index ["parent_id"], name: "index_locations_on_parent_id"
  end

  create_table "packing_groups", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "number", null: false
    t.text "description"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name", null: false
  end

end
