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

ActiveRecord::Schema[8.0].define(version: 2025_04_27_033315) do
  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "categories_places", force: :cascade do |t|
    t.integer "category_id"
    t.integer "place_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "place_id"], name: "index_categories_places_on_category_id_and_place_id", unique: true
    t.index ["category_id"], name: "index_categories_places_on_category_id"
    t.index ["place_id"], name: "index_categories_places_on_place_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "iso_alpha3"
    t.integer "weight", default: 0
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_countries_on_active"
    t.index ["iso_alpha3"], name: "index_countries_on_iso_alpha3", unique: true
    t.index ["weight"], name: "index_countries_on_weight"
  end

  create_table "geo_terms", force: :cascade do |t|
    t.string "term"
    t.json "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term"], name: "index_geo_terms_on_term", unique: true
  end

  create_table "place_feedbacks", force: :cascade do |t|
    t.string "reason"
    t.text "details"
    t.integer "place_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_place_feedbacks_on_place_id"
  end

  create_table "place_hours", force: :cascade do |t|
    t.integer "place_id"
    t.integer "from_hour"
    t.integer "to_hour"
    t.integer "day"
    t.index ["day"], name: "index_place_hours_on_day"
    t.index ["from_hour"], name: "index_place_hours_on_from_hour"
    t.index ["place_id", "day", "from_hour", "to_hour"], name: "idx_on_place_id_day_from_hour_to_hour_7c13b613f5", unique: true
    t.index ["place_id"], name: "index_place_hours_on_place_id"
    t.index ["to_hour"], name: "index_place_hours_on_to_hour"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.string "address"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lng", precision: 10, scale: 6
    t.string "city"
    t.string "region"
    t.string "phone"
    t.string "url"
    t.string "logo"
    t.string "postal_code"
    t.string "email"
    t.text "charity_support"
    t.text "location_instructions"
    t.boolean "pickup", default: false
    t.boolean "used_ok", default: true
    t.boolean "is_bin", default: false
    t.boolean "tax_receipt", default: false
    t.integer "osm_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "country_id"
    t.index ["country_id"], name: "index_places_on_country_id"
    t.index ["is_bin"], name: "index_places_on_is_bin"
    t.index ["pickup"], name: "index_places_on_pickup"
    t.index ["slug"], name: "index_places_on_slug", unique: true
    t.index ["status"], name: "index_places_on_status"
    t.index ["tax_receipt"], name: "index_places_on_tax_receipt"
    t.index ["used_ok"], name: "index_places_on_used_ok"
  end

  add_foreign_key "place_feedbacks", "places"
  add_foreign_key "place_hours", "places"
  add_foreign_key "places", "countries"
end
