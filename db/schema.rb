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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130623065520) do

  create_table "comments", :force => true do |t|
    t.integer  "topic_id",   :null => false
    t.text     "topic_type", :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.text     "text",       :null => false
  end

  add_index "comments", ["topic_id"], :name => "index_comments_on_topic_id"
  add_index "comments", ["topic_type"], :name => "index_comments_on_topic_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contests", :force => true do |t|
    t.text     "name",        :null => false
    t.datetime "start",       :null => false
    t.datetime "end",         :null => false
    t.text     "description", :null => false
    t.boolean  "delta",       :null => false
  end

  create_table "contests_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "contest_id"
  end

  add_index "contests_users", ["contest_id", "user_id"], :name => "contests_users_contest_id_user_id_key", :unique => true
  add_index "contests_users", ["contest_id", "user_id"], :name => "index_contests_users_on_contest_id_and_user_id", :unique => true

  create_table "participants", :force => true do |t|
    t.integer "contest_id",                  :null => false
    t.integer "user_id",                     :null => false
    t.integer "rank"
    t.float   "points",     :default => 0.0
  end

  add_index "participants", ["contest_id", "user_id"], :name => "index_participants_on_contest_id_and_user_id", :unique => true
  add_index "participants", ["contest_id"], :name => "index_participants_on_contest_id"
  add_index "participants", ["user_id"], :name => "index_participants_on_user_id"

  create_table "posts", :force => true do |t|
    t.boolean  "delta"
    t.integer  "author_id",  :null => false
    t.text     "category",   :null => false
    t.text     "title",      :null => false
    t.text     "body",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "problem_tests", :force => true do |t|
    t.integer "problem_id",       :null => false
    t.boolean "hidden",           :null => false
    t.text    "input_file_name"
    t.text    "output_file_name"
  end

  add_index "problem_tests", ["problem_id"], :name => "index_problem_tests_on_problem_id"

  create_table "problems", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "contest_id"
    t.integer  "time",          :default => 1,  :null => false
    t.integer  "memory",        :default => 64, :null => false
    t.text     "name",                          :null => false
    t.text     "text",                          :null => false
    t.datetime "created_at",                    :null => false
    t.text     "source"
    t.boolean  "delta",                         :null => false
    t.datetime "active_from"
    t.datetime "inactive_from"
    t.integer  "tried_count",   :default => 0
    t.integer  "solved_count",  :default => 0
    t.integer  "tests_count",   :default => 0
  end

  add_index "problems", ["contest_id"], :name => "index_problems_on_contest_id"
  add_index "problems", ["user_id"], :name => "index_problems_on_user_id"

  create_table "results", :force => true do |t|
    t.integer  "solution_id",                        :null => false
    t.integer  "test_id",                            :null => false
    t.boolean  "matched",                            :null => false
    t.integer  "time",               :default => 3,  :null => false
    t.integer  "memory",             :default => 64, :null => false
    t.boolean  "hidden"
    t.integer  "execution",          :default => 0,  :null => false
    t.text     "output_file_name"
    t.integer  "output_file_size"
    t.text     "output_fingerprint"
    t.datetime "output_updated_at"
    t.text     "diff_file_name"
    t.integer  "diff_file_size"
    t.text     "diff_fingerprint"
    t.datetime "diff_updated_at"
  end

  add_index "results", ["solution_id"], :name => "index_results_on_solution_id"
  add_index "results", ["test_id"], :name => "index_results_on_test_id"

  create_table "solutions", :force => true do |t|
    t.integer  "problem_id",                         :null => false
    t.integer  "user_id",                            :null => false
    t.float    "percent",                            :null => false
    t.float    "time",                               :null => false
    t.datetime "created_at",                         :null => false
    t.integer  "contest_id"
    t.text     "source_file_name"
    t.datetime "source_updated_at"
    t.float    "point"
    t.text     "junk"
    t.integer  "solved_in"
    t.text     "state"
    t.integer  "source_file_size"
    t.text     "language",           :default => "", :null => false
    t.text     "source_fingerprint"
  end

  add_index "solutions", ["contest_id"], :name => "index_solutions_on_contest_id"
  add_index "solutions", ["problem_id"], :name => "index_solutions_on_problem_id"
  add_index "solutions", ["user_id"], :name => "index_solutions_on_user_id"

  create_table "users", :force => true do |t|
    t.text     "login",                              :null => false
    t.text     "email",                              :null => false
    t.text     "crypted_password"
    t.text     "salt"
    t.datetime "created_at"
    t.text     "school"
    t.boolean  "admin"
    t.boolean  "judge"
    t.text     "persistence_token"
    t.text     "single_access_token"
    t.text     "perishable_token"
    t.text     "password_salt"
    t.integer  "solutions_count",     :default => 0
    t.float    "points"
    t.boolean  "mailed"
    t.text     "web"
    t.text     "twitter"
    t.boolean  "notify_new_contests"
  end

  add_index "users", ["login"], :name => "index_users_on_login"

end
