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

ActiveRecord::Schema[7.0].define(version: 2024_10_11_103957) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "apify_runs", force: :cascade do |t|
    t.integer "channel_id"
    t.string "apify_run_id"
    t.string "apify_dataset_id"
    t.integer "state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "channel_processes", force: :cascade do |t|
    t.integer "channel_id"
    t.integer "count_videos"
    t.boolean "finished", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "channel_video_processes", force: :cascade do |t|
    t.integer "channel_id"
    t.integer "count_videos_processing"
    t.boolean "finished"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "channels", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "external_source"
    t.string "external_source_id"
    t.datetime "checked_at"
    t.integer "state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hack_validations", force: :cascade do |t|
    t.integer "hack_id"
    t.text "analysis"
    t.boolean "status"
    t.string "links"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hacks", force: :cascade do |t|
    t.integer "video_id"
    t.string "title"
    t.string "summary"
    t.text "justification"
    t.boolean "is_hack"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "process_video_logs", force: :cascade do |t|
    t.integer "video_id"
    t.boolean "transcribed", default: false
    t.boolean "has_hacks", default: false
    t.boolean "has_queries", default: false
    t.boolean "has_scraped_pages", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "analysed", default: false
  end

  create_table "prompts", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.text "prompt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "system_prompt"
  end

  create_table "queries", force: :cascade do |t|
    t.integer "hack_id"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scraped_results", force: :cascade do |t|
    t.integer "query_id"
    t.integer "validation_source_id"
    t.string "link"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transcriptions", force: :cascade do |t|
    t.integer "video_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "validation_sources", force: :cascade do |t|
    t.string "name"
    t.string "url_query"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "videos", force: :cascade do |t|
    t.integer "channel_id"
    t.integer "state", default: 0
    t.datetime "processed_at"
    t.datetime "external_created_at"
    t.string "external_source", default: "tiktok"
    t.string "external_source_id"
    t.integer "duration"
    t.integer "digg_count"
    t.integer "comment_count"
    t.integer "share_count"
    t.integer "play_count"
    t.string "source_download_link"
    t.string "source_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
