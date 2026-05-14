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

ActiveRecord::Schema.define(version: 2026_04_30_135025) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.string "address"
  end

  create_table "expenses", force: :cascade do |t|
    t.bigint "trip_id"
    t.date "date"
    t.integer "amount"
    t.string "description"
    t.bigint "golfer_id"
    t.index ["golfer_id"], name: "index_expenses_on_golfer_id"
    t.index ["trip_id"], name: "index_expenses_on_trip_id"
  end

  create_table "golfer_nights", force: :cascade do |t|
    t.bigint "golfer_id"
    t.bigint "night_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["golfer_id", "night_id"], name: "index_golfer_nights_on_golfer_id_and_night_id", unique: true
    t.index ["golfer_id"], name: "index_golfer_nights_on_golfer_id"
    t.index ["night_id"], name: "index_golfer_nights_on_night_id"
  end

  create_table "golfer_rounds", force: :cascade do |t|
    t.bigint "golfer_id"
    t.bigint "round_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["golfer_id", "round_id"], name: "index_golfer_rounds_on_golfer_id_and_round_id", unique: true
    t.index ["golfer_id"], name: "index_golfer_rounds_on_golfer_id"
    t.index ["round_id"], name: "index_golfer_rounds_on_round_id"
  end

  create_table "golfer_trips", force: :cascade do |t|
    t.bigint "golfer_id"
    t.bigint "trip_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_full_trip"
    t.integer "cost"
    t.boolean "is_paid", default: false
    t.integer "balance"
    t.index ["golfer_id", "trip_id"], name: "index_golfer_trips_on_golfer_id_and_trip_id", unique: true
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
    t.string "nickname"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.integer "t_shirt_size"
    t.index ["password_reset_token"], name: "index_golfers_on_password_reset_token", unique: true, where: "(password_reset_token IS NOT NULL)"
  end

  create_table "nights", force: :cascade do |t|
    t.date "date"
    t.integer "cost"
    t.bigint "trip_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_nights_on_trip_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "golfer_trip_id"
    t.index ["golfer_trip_id"], name: "index_payments_on_golfer_trip_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.date "date"
    t.integer "cost"
    t.bigint "trip_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "course_id"
    t.string "tee_time"
    t.index ["trip_id"], name: "index_rounds_on_trip_id"
  end

  create_table "trip_financial_summaries", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.integer "total_revenue", null: false
    t.integer "total_expenses", null: false
    t.integer "total_deficit", null: false
    t.integer "fair_share", null: false
    t.integer "committee_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_trip_financial_summaries_on_trip_id", unique: true
  end

  create_table "trips", force: :cascade do |t|
    t.integer "year"
    t.string "number"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_date"
    t.boolean "completed", default: false, null: false
  end

  add_foreign_key "expenses", "golfers"
  add_foreign_key "expenses", "trips"
  add_foreign_key "golfer_nights", "golfers"
  add_foreign_key "golfer_nights", "nights"
  add_foreign_key "golfer_rounds", "golfers"
  add_foreign_key "golfer_rounds", "rounds"
  add_foreign_key "golfer_trips", "golfers"
  add_foreign_key "golfer_trips", "trips"
  add_foreign_key "nights", "trips"
  add_foreign_key "payments", "golfer_trips"
  add_foreign_key "rounds", "trips"
  add_foreign_key "trip_financial_summaries", "trips"
end
