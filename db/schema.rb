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

ActiveRecord::Schema.define(version: 20180415030052) do

  create_table "adjustments", id: false, force: :cascade do |t|
    t.integer "amount"
    t.string "description"
    t.string "franchise_id"
  end

  create_table "contracts", id: false, force: :cascade do |t|
    t.integer "player_id"
    t.string "contract_terms"
    t.string "roster_status"
    t.integer "acquired_cost"
    t.string "notes"
    t.integer "salary"
    t.string "franchise_id"
  end

  create_table "franchises", id: false, force: :cascade do |t|
    t.string "franchise_id", null: false
    t.string "name"
    t.index ["franchise_id"], name: "index_franchises_on_franchise_id", unique: true
  end

  create_table "players", id: false, force: :cascade do |t|
    t.integer "player_id", null: false
    t.string "name"
    t.string "team"
    t.string "position"
    t.index ["player_id"], name: "index_players_on_player_id", unique: true
  end

  create_table "stats", force: :cascade do |t|
    t.integer "score"
    t.string "position"
    t.integer "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rank"
    t.integer "year"
    t.index ["player_id"], name: "index_stats_on_player_id"
  end

end
