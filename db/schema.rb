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

ActiveRecord::Schema.define(version: 20160303022746) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_roles", force: :cascade do |t|
    t.integer  "account_id", null: false
    t.integer  "role_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_roles", ["account_id", "role_id"], name: "index_account_roles_on_account_id_and_role_id", unique: true, using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.integer  "failed_logins_count",             default: 0
    t.datetime "lock_expires_at"
    t.string   "unlock_token"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "last_login_from_ip_address"
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["last_logout_at", "last_activity_at"], name: "index_accounts_on_last_logout_at_and_last_activity_at", using: :btree
  add_index "accounts", ["remember_me_token"], name: "index_accounts_on_remember_me_token", using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", using: :btree

  create_table "authentications", force: :cascade do |t|
    t.integer  "account_id",                    null: false
    t.string   "provider",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slack_team_name",               null: false
    t.string   "slack_team_id",                 null: false
    t.string   "slack_user_id",                 null: false
    t.string   "slack_token",      default: ""
    t.string   "slack_user_name",               null: false
    t.string   "slack_first_name"
    t.string   "slack_last_name"
  end

  add_index "authentications", ["slack_team_id"], name: "index_authentications_on_slack_team_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "title",                            null: false
    t.text     "description"
    t.string   "tracker"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "public",           default: false, null: false
    t.integer  "owner_account_id",                 null: false
    t.string   "slack_team_id",                    null: false
    t.string   "image_id"
    t.string   "slack_team_name"
  end

  add_index "projects", ["owner_account_id"], name: "index_projects_on_owner_account_id", using: :btree
  add_index "projects", ["public"], name: "index_projects_on_public", using: :btree
  add_index "projects", ["slack_team_id", "public"], name: "index_projects_on_slack_team_id_and_public", using: :btree

  create_table "reward_types", force: :cascade do |t|
    t.integer  "project_id", null: false
    t.string   "name",       null: false
    t.integer  "amount",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rewards", force: :cascade do |t|
    t.integer  "account_id",     null: false
    t.integer  "issuer_id",      null: false
    t.text     "description"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "reward_type_id", null: false
  end

  add_index "rewards", ["account_id"], name: "index_rewards_on_account_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "key",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
