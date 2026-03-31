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

ActiveRecord::Schema[8.1].define(version: 2026_03_31_174136) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.string "author"
    t.boolean "bookmarked", default: false, null: false
    t.datetime "bookmarked_at"
    t.integer "comments_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "external_id", null: false
    t.datetime "published_at"
    t.datetime "read_at"
    t.integer "score", default: 0
    t.datetime "scraped_at", null: false
    t.string "source", null: false
    t.string "source_name"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["bookmarked"], name: "index_articles_on_bookmarked"
    t.index ["discarded_at"], name: "index_articles_on_discarded_at"
    t.index ["published_at"], name: "index_articles_on_published_at"
    t.index ["read_at"], name: "index_articles_on_read_at"
    t.index ["score"], name: "index_articles_on_score"
    t.index ["source", "external_id"], name: "index_articles_on_source_and_external_id", unique: true
    t.index ["source"], name: "index_articles_on_source"
  end

  create_table "newsletter_articles", force: :cascade do |t|
    t.integer "article_id", null: false
    t.text "commentary"
    t.datetime "created_at", null: false
    t.integer "newsletter_id", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_newsletter_articles_on_article_id"
    t.index ["newsletter_id", "article_id"], name: "index_newsletter_articles_on_newsletter_id_and_article_id", unique: true
    t.index ["newsletter_id"], name: "index_newsletter_articles_on_newsletter_id"
  end

  create_table "newsletters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.datetime "published_at"
    t.datetime "sent_at"
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_newsletters_on_slug", unique: true
  end

  create_table "subscribers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "email", null: false
    t.string "unsubscribe_reason"
    t.string "unsubscribe_token"
    t.datetime "unsubscribed_at"
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_subscribers_on_discarded_at"
    t.index ["email"], name: "index_subscribers_on_email", unique: true
    t.index ["unsubscribe_token"], name: "index_subscribers_on_unsubscribe_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "newsletter_articles", "articles"
  add_foreign_key "newsletter_articles", "newsletters"
end
