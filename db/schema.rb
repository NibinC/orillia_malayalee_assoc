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

ActiveRecord::Schema[7.2].define(version: 2025_10_27_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "association_events", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "starts_at"
    t.integer "adult_price_cents"
    t.integer "minor_price_cents"
    t.string "currency"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendees", force: :cascade do |t|
    t.bigint "registration_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.date "dob"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registration_id"], name: "index_attendees_on_registration_id"
  end

  create_table "event_registrations", force: :cascade do |t|
    t.bigint "association_event_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "total_cents"
    t.string "currency"
    t.string "status"
    t.string "stripe_checkout_session_id"
    t.string "stripe_payment_intent_id"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["association_event_id"], name: "index_event_registrations_on_association_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "starts_at"
    t.integer "adult_price_cents"
    t.integer "minor_price_cents"
    t.string "currency"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registrations", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "total_cents"
    t.string "currency"
    t.string "status"
    t.string "stripe_checkout_session_id"
    t.string "stripe_payment_intent_id"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_registrations_on_event_id"
  end

  add_foreign_key "attendees", "registrations"
  add_foreign_key "event_registrations", "association_events"
  add_foreign_key "registrations", "events"
end
