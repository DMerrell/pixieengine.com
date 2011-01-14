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

ActiveRecord::Schema.define(:version => 20110114074844) do

  create_table "access_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",       :limit => 30
    t.string   "key"
    t.string   "token",      :limit => 1024
    t.string   "secret"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_tokens", ["key"], :name => "index_access_tokens_on_key", :unique => true

  create_table "alternatives", :force => true do |t|
    t.integer "experiment_id"
    t.string  "content"
    t.string  "lookup",        :limit => 32
    t.integer "weight",                      :default => 1
    t.integer "participants",                :default => 0
    t.integer "conversions",                 :default => 0
  end

  add_index "alternatives", ["experiment_id"], :name => "index_alternatives_on_experiment_id"
  add_index "alternatives", ["lookup"], :name => "index_alternatives_on_lookup"

  create_table "app_data", :force => true do |t|
    t.integer  "app_id",     :null => false
    t.string   "name",       :null => false
    t.text     "json",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "app_libraries", :force => true do |t|
    t.integer  "app_id",     :null => false
    t.integer  "library_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "app_libraries", ["app_id", "library_id"], :name => "index_app_libraries_on_app_id_and_library_id", :unique => true
  add_index "app_libraries", ["app_id"], :name => "index_app_libraries_on_app_id"
  add_index "app_libraries", ["library_id"], :name => "index_app_libraries_on_library_id"

  create_table "app_members", :force => true do |t|
    t.integer  "app_id",     :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "app_members", ["app_id", "user_id"], :name => "index_app_members_on_app_id_and_user_id", :unique => true
  add_index "app_members", ["app_id"], :name => "index_app_members_on_app_id"
  add_index "app_members", ["user_id"], :name => "index_app_members_on_user_id"

  create_table "app_sprites", :force => true do |t|
    t.integer  "app_id",     :null => false
    t.integer  "sprite_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name",       :null => false
  end

  add_index "app_sprites", ["app_id", "name"], :name => "index_app_sprites_on_app_id_and_name", :unique => true
  add_index "app_sprites", ["app_id", "sprite_id"], :name => "index_app_sprites_on_app_id_and_sprite_id", :unique => true
  add_index "app_sprites", ["app_id"], :name => "index_app_sprites_on_app_id"
  add_index "app_sprites", ["sprite_id"], :name => "index_app_sprites_on_sprite_id"

  create_table "apps", :force => true do |t|
    t.integer  "user_id",                                 :null => false
    t.string   "title",                                   :null => false
    t.text     "description"
    t.text     "html"
    t.text     "code"
    t.text     "test"
    t.integer  "parent_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "width",       :default => 480
    t.integer  "height",      :default => 300
    t.text     "src"
    t.string   "lang",        :default => "coffeescript"
  end

  create_table "archived_sounds", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.string   "wav_file_name"
    t.string   "wav_content_type"
    t.integer  "wav_file_size"
    t.datetime "wav_uploaded_at"
    t.string   "sfs_file_name"
    t.string   "sfs_content_type"
    t.integer  "sfs_file_size"
    t.datetime "sfs_uploaded_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "mp3_file_name"
    t.string   "mp3_content_type"
    t.integer  "mp3_file_size"
    t.datetime "mp3_updated_at"
  end

  create_table "archived_sprites", :id => false, :force => true do |t|
    t.integer  "id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "width"
    t.integer  "height"
    t.integer  "frames"
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.integer  "parent_id"
    t.integer  "comments_count"
    t.datetime "deleted_at"
    t.boolean  "replayable",         :default => false, :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "chats", :force => true do |t|
    t.integer  "user_id"
    t.text     "text",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "chats", ["created_at"], :name => "index_chats_on_created_at"

  create_table "collection_items", :force => true do |t|
    t.integer  "collection_id", :null => false
    t.integer  "item_id",       :null => false
    t.string   "item_type",     :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "collection_items", ["collection_id"], :name => "index_collection_items_on_collection_id"
  add_index "collection_items", ["item_id", "item_type"], :name => "index_collection_items_on_item_id_and_item_type"

  create_table "collections", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.string   "name",                          :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "comments_count", :default => 0, :null => false
  end

  add_index "collections", ["user_id"], :name => "index_collections_on_user_id"

  create_table "comments", :force => true do |t|
    t.integer  "commenter_id",     :null => false
    t.integer  "commentable_id",   :null => false
    t.string   "commentable_type", :null => false
    t.text     "body",             :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["commenter_id"], :name => "index_comments_on_commenter_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "experiments", :force => true do |t|
    t.string   "test_name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "experiments", ["test_name"], :name => "index_experiments_on_test_name"

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.text     "body",          :null => false
    t.string   "email_address"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "invites", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "email",      :null => false
    t.string   "token",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "to",         :null => false
  end

  create_table "libraries", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "title",       :null => false
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "library_components", :force => true do |t|
    t.integer  "library_id",           :null => false
    t.integer  "component_library_id", :null => false
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "library_components", ["component_library_id"], :name => "index_library_components_on_component_library_id"
  add_index "library_components", ["library_id", "component_library_id"], :name => "index_library_components_on_library_id_and_component_library_id", :unique => true
  add_index "library_components", ["library_id"], :name => "index_library_components_on_library_id"

  create_table "library_scripts", :force => true do |t|
    t.integer  "library_id", :null => false
    t.integer  "script_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "library_scripts", ["library_id", "script_id"], :name => "index_library_scripts_on_library_id_and_script_id", :unique => true
  add_index "library_scripts", ["library_id"], :name => "index_library_scripts_on_library_id"
  add_index "library_scripts", ["script_id"], :name => "index_library_scripts_on_script_id"

  create_table "links", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.integer  "target_id",                 :null => false
    t.string   "target_type",               :null => false
    t.string   "token",       :limit => 16, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "links", ["token"], :name => "index_links_on_token", :unique => true

  create_table "plugins", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "approved",    :default => false, :null => false
    t.string   "plugin_type",                    :null => false
    t.string   "title",                          :null => false
    t.text     "description"
    t.text     "code",                           :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "parent_id"
  end

  create_table "script_members", :force => true do |t|
    t.integer  "script_id",  :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "script_members", ["script_id", "user_id"], :name => "index_script_members_on_script_id_and_user_id", :unique => true
  add_index "script_members", ["script_id"], :name => "index_script_members_on_script_id"
  add_index "script_members", ["user_id"], :name => "index_script_members_on_user_id"

  create_table "scripts", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "approved",    :default => false,          :null => false
    t.string   "script_type",                             :null => false
    t.string   "title",                                   :null => false
    t.text     "description"
    t.text     "code",                                    :null => false
    t.text     "test"
    t.integer  "parent_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.text     "src"
    t.string   "lang",        :default => "coffeescript"
    t.text     "test_src"
  end

  create_table "sounds", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.string   "wav_file_name"
    t.string   "wav_content_type"
    t.integer  "wav_file_size"
    t.datetime "wav_uploaded_at"
    t.string   "sfs_file_name"
    t.string   "sfs_content_type"
    t.integer  "sfs_file_size"
    t.datetime "sfs_uploaded_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "mp3_file_name"
    t.string   "mp3_content_type"
    t.integer  "mp3_file_size"
    t.datetime "mp3_updated_at"
  end

  create_table "sprites", :force => true do |t|
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "width",                                 :null => false
    t.integer  "height",                                :null => false
    t.integer  "frames",             :default => 1,     :null => false
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.integer  "parent_id"
    t.integer  "comments_count",     :default => 0,     :null => false
    t.boolean  "replayable",         :default => false, :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id",        :null => false
    t.integer  "taggable_id",   :null => false
    t.string   "taggable_type", :null => false
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :null => false
    t.datetime "created_at",    :null => false
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "tilemaps", :force => true do |t|
    t.string   "title",                             :null => false
    t.integer  "parent_id"
    t.integer  "width",                             :null => false
    t.integer  "height",                            :null => false
    t.integer  "tile_width",        :default => 32, :null => false
    t.integer  "tile_height",       :default => 32, :null => false
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "user_id"
  end

  create_table "user_plugins", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "plugin_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_plugins", ["user_id", "plugin_id"], :name => "index_user_plugins_on_user_id_and_plugin_id", :unique => true
  add_index "user_plugins", ["user_id"], :name => "index_user_plugins_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                      :null => false
    t.string   "single_access_token",                    :null => false
    t.string   "perishable_token",                       :null => false
    t.integer  "login_count",         :default => 0,     :null => false
    t.integer  "failed_login_count",  :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "display_name"
    t.integer  "referrer_id"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.integer  "active_token_id"
    t.boolean  "admin",               :default => false, :null => false
    t.integer  "comments_count",      :default => 0,     :null => false
    t.text     "profile"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "subscribed",          :default => true,  :null => false
    t.string   "favorite_color"
  end

  add_index "users", ["oauth_token"], :name => "index_users_on_oauth_token"

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "modifications"
    t.integer  "number"
    t.integer  "reverted_from"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

  create_table "visits", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "controller", :null => false
    t.string   "action",     :null => false
    t.datetime "created_at", :null => false
  end

  add_index "visits", ["user_id"], :name => "index_visits_on_user_id"

end
