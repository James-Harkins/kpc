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

ActiveRecord::Schema.define(version: 2024_08_02_000603) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "golfer_nights", force: :cascade do |t|
    t.bigint "golfer_id"
    t.bigint "night_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["golfer_id"], name: "index_golfer_nights_on_golfer_id"
    t.index ["night_id"], name: "index_golfer_nights_on_night_id"
  end

  create_table "golfer_rounds", force: :cascade do |t|
    t.bigint "golfer_id"
    t.bigint "round_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["golfer_id"], name: "index_golfer_rounds_on_golfer_id"
    t.index ["round_id"], name: "index_golfer_rounds_on_round_id"
  end

  create_table "golfer_trips", force: :cascade do |t|
    t.bigint "golfer_id"
    t.bigint "trip_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_full_trip"
    t.index ["golfer_id"], name: "index_golfer_trips_on_golfer_id"
    t.index ["trip_id"], name: "index_golfer_trips_on_trip_id"
  end

  create_table "golfers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.integer "role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nights", force: :cascade do |t|
    t.date "date"
    t.float "cost"
    t.bigint "trip_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_nights_on_trip_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.date "date"
    t.float "cost"
    t.bigint "trip_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_rounds_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.integer "year"
    t.string "number"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_date"
  end

  add_foreign_key "golfer_nights", "golfers"
  add_foreign_key "golfer_nights", "nights"
  add_foreign_key "golfer_rounds", "golfers"
  add_foreign_key "golfer_rounds", "rounds"
  add_foreign_key "golfer_trips", "golfers"
  add_foreign_key "golfer_trips", "trips"
  add_foreign_key "nights", "trips"
  add_foreign_key "rounds", "trips"
end
