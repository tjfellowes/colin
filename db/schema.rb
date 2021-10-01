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

ActiveRecord::Schema.define(version: 2021_09_27_154121) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chemical_haz_classes", force: :cascade do |t|
    t.bigint "chemical_id"
    t.bigint "haz_class_id"
    t.string "category"
    t.index ["chemical_id"], name: "index_chemical_haz_classes_on_chemical_id"
    t.index ["haz_class_id"], name: "index_chemical_haz_classes_on_haz_class_id"
  end

  create_table "chemical_haz_stats", force: :cascade do |t|
    t.bigint "chemical_id"
    t.bigint "haz_stat_id"
    t.index ["chemical_id"], name: "index_chemical_haz_stats_on_chemical_id"
    t.index ["haz_stat_id"], name: "index_chemical_haz_stats_on_haz_stat_id"
  end

  create_table "chemical_pictograms", force: :cascade do |t|
    t.bigint "chemical_id"
    t.bigint "pictogram_id"
    t.index ["chemical_id"], name: "index_chemical_pictograms_on_chemical_id"
    t.index ["pictogram_id"], name: "index_chemical_pictograms_on_pictogram_id"
  end

  create_table "chemical_prec_stat_supps", force: :cascade do |t|
    t.bigint "chemical_prec_stat_id"
    t.integer "position", null: false
    t.string "information", null: false
    t.index ["chemical_prec_stat_id"], name: "index_chemical_prec_stat_supps_on_chemical_prec_stat_id"
  end

  create_table "chemical_prec_stats", force: :cascade do |t|
    t.bigint "chemical_id"
    t.bigint "prec_stat_id"
    t.index ["chemical_id"], name: "index_chemical_prec_stats_on_chemical_id"
    t.index ["prec_stat_id"], name: "index_chemical_prec_stats_on_prec_stat_id"
  end

  create_table "chemicals", force: :cascade do |t|
    t.string "cas", null: false
    t.string "prefix"
    t.string "name", null: false
    t.boolean "haz_substance", null: false
    t.string "sds_url"
    t.string "un_number"
    t.bigint "dg_class_id"
    t.bigint "dg_class_2_id"
    t.bigint "dg_class_3_id"
    t.bigint "schedule_id"
    t.bigint "packing_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "storage_temperature_min"
    t.string "storage_temperature_max"
    t.string "un_proper_shipping_name"
    t.binary "sds"
    t.bigint "signal_word_id"
    t.string "inchi"
    t.string "smiles"
    t.string "pubchem"
    t.float "density"
    t.float "melting_point"
    t.float "boiling_point"
    t.index ["dg_class_2_id"], name: "index_chemicals_on_dg_class_2_id"
    t.index ["dg_class_3_id"], name: "index_chemicals_on_dg_class_3_id"
    t.index ["dg_class_id"], name: "index_chemicals_on_dg_class_id"
    t.index ["packing_group_id"], name: "index_chemicals_on_packing_group_id"
    t.index ["schedule_id"], name: "index_chemicals_on_schedule_id"
    t.index ["signal_word_id"], name: "index_chemicals_on_signal_word_id"
  end

  create_table "container_locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "container_id", null: false
    t.bigint "location_id"
    t.boolean "temp", default: false, null: false
    t.index ["container_id"], name: "index_container_locations_on_container_id"
    t.index ["location_id"], name: "index_container_locations_on_location_id"
  end

  create_table "containers", force: :cascade do |t|
    t.string "barcode"
    t.float "container_size"
    t.string "size_unit"
    t.datetime "date_purchased", null: false
    t.datetime "expiry_date"
    t.datetime "date_disposed"
    t.bigint "chemical_id", null: false
    t.bigint "supplier_id"
    t.string "description"
    t.string "product_number"
    t.string "lot_number"
    t.bigint "user_id"
    t.bigint "owner_id"
    t.binary "picture"
    t.index ["chemical_id"], name: "index_containers_on_chemical_id"
    t.index ["owner_id"], name: "index_containers_on_owner_id"
    t.index ["supplier_id"], name: "index_containers_on_supplier_id"
    t.index ["user_id"], name: "index_containers_on_user_id"
  end

  create_table "dg_classes", force: :cascade do |t|
    t.text "number", null: false
    t.text "description", null: false
    t.bigint "superclass_id"
    t.index ["superclass_id"], name: "index_dg_classes_on_superclass_id"
  end

  create_table "haz_classes", force: :cascade do |t|
    t.string "description"
  end

  create_table "haz_stats", force: :cascade do |t|
    t.string "code"
    t.string "description"
  end

  create_table "location_standards", force: :cascade do |t|
    t.bigint "locations_id"
    t.bigint "standards_id"
    t.index ["locations_id"], name: "index_location_standards_on_locations_id"
    t.index ["standards_id"], name: "index_location_standards_on_standards_id"
  end

  create_table "location_types", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "code"
    t.string "barcode"
    t.bigint "location_types_id"
    t.string "temperature"
    t.boolean "monitored", default: false, null: false
    t.string "ancestry"
    t.index ["location_types_id"], name: "index_locations_on_location_types_id"
  end

  create_table "packing_groups", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "pictograms", force: :cascade do |t|
    t.string "name"
    t.binary "picture"
  end

  create_table "prec_stats", force: :cascade do |t|
    t.string "code"
    t.string "description"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "number", null: false
    t.text "description"
  end

  create_table "signal_words", force: :cascade do |t|
    t.string "name"
  end

  create_table "standards", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name", null: false
    t.string "website"
  end

  create_table "users", force: :cascade do |t|
    t.text "username", null: false
    t.text "name", null: false
    t.text "email", null: false
    t.text "password_digest", null: false
    t.bigint "supervisor_id"
    t.boolean "isadmin", default: false
    t.boolean "issuperuser", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supervisor_id"], name: "index_users_on_supervisor_id"
  end

  add_foreign_key "containers", "users", column: "owner_id"
end
