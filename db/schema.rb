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

ActiveRecord::Schema.define(version: 20171111235640) do

  create_table "chemicals", force: :cascade do |t|
    t.string "cas", null: false
    t.string "prefix", null: false
    t.string "name", null: false
    t.boolean "haz_substance", null: false
    t.string "sds_url", null: false
    t.string "un_number"
    t.integer "dg_class_id"
    t.integer "schedule_id"
    t.integer "packing_group_id"
    t.integer "subrisk_id"
    t.integer "dg_classes_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dg_class_id"], name: "index_chemicals_on_dg_class_id"
    t.index ["dg_classes_id"], name: "index_chemicals_on_dg_classes_id"
    t.index ["packing_group_id"], name: "index_chemicals_on_packing_group_id"
    t.index ["schedule_id"], name: "index_chemicals_on_schedule_id"
    t.index ["subrisk_id"], name: "index_chemicals_on_subrisk_id"
  end

  create_table "dg_class_division", force: :cascade do |t|
    t.integer "number", null: false
    t.text "description", null: false
    t.integer "class_id", null: false
    t.integer "subrisk_id"
    t.index ["class_id"], name: "index_dg_class_division_on_class_id"
    t.index ["subrisk_id"], name: "index_dg_class_division_on_subrisk_id"
  end

  create_table "dg_classes", force: :cascade do |t|
    t.integer "number", null: false
    t.text "description", null: false
    t.integer "superclass_id"
    t.index ["superclass_id"], name: "index_dg_classes_on_superclass_id"
  end

  create_table "packing_groups", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "number", null: false
    t.text "description"
  end

end
