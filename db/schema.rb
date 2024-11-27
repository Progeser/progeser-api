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

ActiveRecord::Schema[7.2].define(version: 2024_11_27_095600) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_requests", force: :cascade do |t|
    t.string "email", null: false
    t.string "creation_token", null: false
    t.string "first_name"
    t.string "last_name"
    t.text "comment"
    t.boolean "accepted", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "laboratory"
    t.string "password_digest"
    t.index ["creation_token"], name: "index_account_requests_on_creation_token", unique: true
    t.index ["email"], name: "index_account_requests_on_email", unique: true
  end

  create_table "benches", force: :cascade do |t|
    t.bigint "greenhouse_id"
    t.string "name"
    t.integer "dimensions", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "positions", array: true
    t.index ["greenhouse_id"], name: "index_benches_on_greenhouse_id"
  end

  create_table "buildings", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "greenhouses", force: :cascade do |t|
    t.string "name", null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.decimal "occupancy", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "building_id"
    t.index ["building_id"], name: "index_greenhouses_on_building_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "plant_stages", force: :cascade do |t|
    t.string "name", null: false
    t.integer "duration"
    t.integer "position", null: false
    t.bigint "plant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plant_id"], name: "index_plant_stages_on_plant_id"
  end

  create_table "plants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pots", force: :cascade do |t|
    t.string "name", null: false
    t.string "shape", null: false
    t.decimal "area", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "dimensions", array: true
  end

  create_table "request_distributions", force: :cascade do |t|
    t.bigint "request_id"
    t.bigint "bench_id"
    t.bigint "plant_stage_id"
    t.bigint "pot_id"
    t.integer "pot_quantity"
    t.decimal "area"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bench_id"], name: "index_request_distributions_on_bench_id"
    t.index ["plant_stage_id"], name: "index_request_distributions_on_plant_stage_id"
    t.index ["pot_id"], name: "index_request_distributions_on_pot_id"
    t.index ["request_id"], name: "index_request_distributions_on_request_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "handler_id"
    t.bigint "plant_stage_id"
    t.string "name"
    t.string "plant_name"
    t.string "plant_stage_name"
    t.string "status"
    t.text "comment"
    t.date "due_date"
    t.integer "quantity"
    t.integer "temperature"
    t.integer "photoperiod"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_requests_on_author_id"
    t.index ["handler_id"], name: "index_requests_on_handler_id"
    t.index ["plant_stage_id"], name: "index_requests_on_plant_stage_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.string "role"
    t.string "first_name"
    t.string "last_name"
    t.string "type"
    t.string "laboratory"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "discarded_at", precision: nil
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "greenhouses", "buildings"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
end
