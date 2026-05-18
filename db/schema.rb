# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_18_094538) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "event_dates", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.date "date", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "date"], name: "index_event_dates_on_event_id_and_date"
    t.index ["event_id"], name: "index_event_dates_on_event_id"
  end

  create_table "event_owners", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.string "cpf"
    t.string "phone_number", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.index ["event_id", "role"], name: "index_event_owners_on_event_id_and_role"
    t.index ["event_id"], name: "index_event_owners_on_event_id"
  end

  create_table "event_providers", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "provider_id", null: false
    t.json "custom_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "provider_id"], name: "index_event_providers_on_event_id_and_provider_id", unique: true
    t.index ["event_id"], name: "index_event_providers_on_event_id"
    t.index ["provider_id"], name: "index_event_providers_on_provider_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "event_type", null: false
    t.date "main_date", null: false
    t.time "start_time"
    t.time "end_time"
    t.string "place"
    t.text "address"
    t.integer "estimated_guests"
    t.decimal "extra_hours", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["event_type"], name: "index_events_on_event_type"
    t.index ["main_date"], name: "index_events_on_main_date"
  end

  create_table "guests", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.string "cpf"
    t.string "phone_number"
    t.boolean "is_godparent", default: false
    t.bigint "godparent_pair_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "name"], name: "index_guests_on_event_id_and_name"
    t.index ["event_id"], name: "index_guests_on_event_id"
    t.index ["godparent_pair_id"], name: "index_guests_on_godparent_pair_id"
    t.index ["is_godparent"], name: "index_guests_on_is_godparent"
  end

  create_table "manager_checklists", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "task", null: false
    t.date "due_date"
    t.boolean "completed", default: false, null: false
    t.date "reminder_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed"], name: "index_manager_checklists_on_completed"
    t.index ["event_id", "due_date"], name: "index_manager_checklists_on_event_id_and_due_date"
    t.index ["event_id"], name: "index_manager_checklists_on_event_id"
  end

  create_table "owner_checklists", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "task", null: false
    t.date "due_date"
    t.boolean "completed", default: false, null: false
    t.date "reminder_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed"], name: "index_owner_checklists_on_completed"
    t.index ["event_id", "due_date"], name: "index_owner_checklists_on_event_id_and_due_date"
    t.index ["event_id"], name: "index_owner_checklists_on_event_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "provider_type", null: false
    t.string "name", null: false
    t.string "document", null: false
    t.string "contact_name", null: false
    t.string "phone_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_type", "name"], name: "index_providers_on_provider_type_and_name"
    t.index ["provider_type"], name: "index_providers_on_provider_type"
  end

  add_foreign_key "event_dates", "events"
  add_foreign_key "event_owners", "events"
  add_foreign_key "event_providers", "events"
  add_foreign_key "event_providers", "providers"
  add_foreign_key "guests", "events"
  add_foreign_key "guests", "guests", column: "godparent_pair_id"
  add_foreign_key "manager_checklists", "events"
  add_foreign_key "owner_checklists", "events"
end
