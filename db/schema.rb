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

ActiveRecord::Schema[8.1].define(version: 2025_11_05_174859) do
  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "categories_places", force: :cascade do |t|
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.integer "place_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "place_id"], name: "index_categories_places_on_category_id_and_place_id", unique: true
    t.index ["category_id"], name: "index_categories_places_on_category_id"
    t.index ["place_id"], name: "index_categories_places_on_place_id"
  end

  create_table "countries", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.string "iso_alpha3", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "weight", default: 0
    t.index ["active"], name: "index_countries_on_active"
    t.index ["iso_alpha3"], name: "index_countries_on_iso_alpha3", unique: true
    t.index ["weight"], name: "index_countries_on_weight"
  end

  create_table "geo_terms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "response", null: false
    t.string "term", null: false
    t.datetime "updated_at", null: false
    t.index ["term"], name: "index_geo_terms_on_term", unique: true
  end

  create_table "geocoder_caches", primary_key: "url", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "response", null: false
    t.datetime "updated_at", null: false
  end

  create_table "place_feedbacks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "details"
    t.integer "place_id", null: false
    t.integer "reason", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["place_id"], name: "index_place_feedbacks_on_place_id"
    t.index ["user_id"], name: "index_place_feedbacks_on_user_id"
  end

  create_table "place_hours", force: :cascade do |t|
    t.integer "day_of_week", null: false
    t.integer "from_hour", null: false
    t.integer "place_id", null: false
    t.integer "to_hour", null: false
    t.index ["day_of_week"], name: "index_place_hours_on_day_of_week"
    t.index ["from_hour"], name: "index_place_hours_on_from_hour"
    t.index ["place_id", "day_of_week", "from_hour", "to_hour"], name: "idx_on_place_id_day_of_week_from_hour_to_hour_8b41e5a11b", unique: true
    t.index ["place_id"], name: "index_place_hours_on_place_id"
    t.index ["to_hour"], name: "index_place_hours_on_to_hour"
  end

  create_table "places", force: :cascade do |t|
    t.string "address", null: false
    t.text "charity_support"
    t.string "city", null: false
    t.integer "country_id", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "email"
    t.boolean "is_bin", default: false, null: false
    t.decimal "lat", precision: 10, scale: 6, null: false
    t.decimal "lng", precision: 10, scale: 6, null: false
    t.text "location_instructions"
    t.string "logo"
    t.string "name", null: false
    t.integer "osm_id"
    t.string "phone"
    t.boolean "pickup", default: false, null: false
    t.string "postal_code"
    t.string "region"
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.boolean "tax_receipt", default: false, null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.boolean "used_ok", default: true, null: false
    t.integer "user_id", null: false
    t.index ["country_id"], name: "index_places_on_country_id"
    t.index ["is_bin"], name: "index_places_on_is_bin"
    t.index ["lat", "lng"], name: "index_places_on_lat_and_lng"
    t.index ["pickup"], name: "index_places_on_pickup"
    t.index ["slug"], name: "index_places_on_slug", unique: true
    t.index ["status"], name: "index_places_on_status"
    t.index ["tax_receipt"], name: "index_places_on_tax_receipt"
    t.index ["used_ok"], name: "index_places_on_used_ok"
    t.index ["user_id"], name: "index_places_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "place_feedbacks", "places"
  add_foreign_key "place_feedbacks", "users"
  add_foreign_key "place_hours", "places"
  add_foreign_key "places", "countries"
  add_foreign_key "places", "users"
  add_foreign_key "sessions", "users"
end
