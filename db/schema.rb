# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151003002438) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "task_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "task_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "task_anc_desc_idx", unique: true, using: :btree
  add_index "task_hierarchies", ["descendant_id"], name: "task_desc_idx", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "name",                            null: false
    t.integer  "reference_id"
    t.string   "goal"
    t.integer  "weight",            default: 1,   null: false
    t.integer  "parent_id"
    t.integer  "status_id",                       null: false
    t.date     "last_done_on"
    t.integer  "done_count",        default: 0,   null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.float    "adjusted_weight",   default: 1.0, null: false
    t.integer  "done_count_offset", default: 0,   null: false
  end

end
