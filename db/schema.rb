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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120622120634) do

  create_table "deal_locations", :force => true do |t|
    t.integer  "deal_id"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "phone_number"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deal_locations", ["deal_id"], :name => "index_deal_locations_on_deal_id"

  create_table "deals", :force => true do |t|
    t.string   "provider"
    t.string   "provider_id"
    t.string   "source"
    t.string   "title"
    t.text     "description"
    t.string   "name"
    t.string   "url",           :limit => 1024
    t.string   "mobile_url",    :limit => 1024
    t.string   "thumbnail_url", :limit => 1024
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deals", ["provider", "provider_id"], :name => "index_deals_on_provider_and_provider_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "city"
    t.string   "state"
    t.string   "venue"
    t.string   "tags"
    t.string   "category"
    t.string   "flyer"
    t.string   "slug"
    t.string   "source"
    t.string   "source_id"
    t.integer  "rank"
    t.string   "url"
    t.string   "thumbnail_url"
    t.boolean  "conference",    :default => false
  end

  add_index "events", ["slug"], :name => "index_events_on_slug", :unique => true

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "locations", :force => true do |t|
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "city"
    t.string   "state"
    t.string   "twitter_name"
    t.string   "phone"
    t.string   "reference"
    t.string   "email"
    t.string   "types"
    t.integer  "accuracy",          :default => 50
    t.string   "facebook_page_id"
    t.string   "general_type"
    t.integer  "user_id"
    t.string   "slug"
    t.boolean  "verified",          :default => false
    t.date     "verified_on"
    t.string   "verified_by"
    t.integer  "favorites_count",   :default => 0
    t.datetime "last_favorited_at"
    t.text     "description"
    t.string   "profile_image_url"
    t.boolean  "active",            :default => true
  end

  add_index "locations", ["slug"], :name => "index_locations_on_slug", :unique => true

  create_table "place_mappings", :force => true do |t|
    t.string   "name"
    t.string   "city"
    t.text     "slug"
    t.integer  "favorites_count",   :default => 0
    t.datetime "last_favorited_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "places_id"
    t.string   "reference"
  end

  add_index "place_mappings", ["places_id"], :name => "index_place_mappings_on_places_id"
  add_index "place_mappings", ["slug"], :name => "index_place_mappings_on_slug", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "roles_mask",                            :default => 1
    t.string   "first_name"
    t.string   "last_name"
    t.string   "city"
    t.string   "state"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
