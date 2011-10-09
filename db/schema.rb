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

ActiveRecord::Schema.define(:version => 20111007032601) do

  create_table "counts", :force => true do |t|
    t.integer  "episode_id"
    t.integer  "speaker_id"
    t.integer  "word_id"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "episodes", :force => true do |t|
    t.integer  "episode"
    t.integer  "season"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scrapers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sentences", :force => true do |t|
    t.integer  "speaker_id"
    t.integer  "episode_id"
    t.text     "sentence"
    t.integer  "num_of_words"
    t.integer  "num_of_chars"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "speakers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "image_path"
  end

  create_table "words", :force => true do |t|
    t.text     "word"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
