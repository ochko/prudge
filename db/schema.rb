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

ActiveRecord::Schema.define(:version => 20130603143300) do

  create_table "comments", :force => true do |t|
    t.integer  "topic_id",                 :null => false
    t.string   "topic_type", :limit => 31, :null => false
    t.integer  "user_id",                  :null => false
    t.datetime "created_at",               :null => false
    t.text     "text",                     :null => false
  end

  add_index "comments", ["topic_id"], :name => "index_comments_on_topic_id"
  add_index "comments", ["topic_type"], :name => "index_comments_on_topic_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contests", :force => true do |t|
    t.string   "name",                           :null => false
    t.datetime "start",                          :null => false
    t.datetime "end",                            :null => false
    t.text     "description",                    :null => false
    t.boolean  "delta",       :default => true,  :null => false
    t.integer  "level",       :default => 0
    t.boolean  "private",     :default => false
  end

  create_table "contests_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "contest_id"
  end

  add_index "contests_users", ["contest_id", "user_id"], :name => "index_contests_users_on_contest_id_and_user_id", :unique => true

  create_table "posts", :force => true do |t|
    t.boolean  "delta",      :default => true
    t.integer  "author_id",                    :null => false
    t.string   "category",                     :null => false
    t.string   "title",                        :null => false
    t.text     "body",                         :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "problem_tests", :force => true do |t|
    t.integer "problem_id",                         :null => false
    t.boolean "hidden",           :default => true, :null => false
    t.string  "input_file_name"
    t.string  "output_file_name"
  end

  add_index "problem_tests", ["problem_id"], :name => "index_problem_tests_on_problem_id"

  create_table "problems", :force => true do |t|
    t.integer  "user_id",                                        :null => false
    t.integer  "contest_id"
    t.integer  "level",                        :default => 1,    :null => false
    t.integer  "time",                         :default => 1,    :null => false
    t.integer  "memory",                       :default => 64,   :null => false
    t.string   "name",          :limit => 128,                   :null => false
    t.text     "text",                                           :null => false
    t.datetime "created_at",                                     :null => false
    t.string   "source"
    t.boolean  "delta",                        :default => true, :null => false
    t.datetime "active_from"
    t.datetime "inactive_from"
    t.integer  "tried_count",                  :default => 0
    t.integer  "solved_count",                 :default => 0
    t.integer  "tests_count",                  :default => 0
  end

  add_index "problems", ["contest_id"], :name => "index_problems_on_contest_id"
  add_index "problems", ["user_id"], :name => "index_problems_on_user_id"

  create_table "results", :force => true do |t|
    t.integer "solution_id",                    :null => false
    t.integer "test_id",                        :null => false
    t.boolean "matched",     :default => false, :null => false
    t.integer "time",        :default => 3,     :null => false
    t.integer "memory",      :default => 64,    :null => false
    t.text    "output",                         :null => false
    t.boolean "hidden",      :default => true
    t.text    "diff"
    t.integer "execution",   :default => 0,     :null => false
  end

  add_index "results", ["solution_id"], :name => "index_results_on_solution_id"
  add_index "results", ["test_id"], :name => "index_results_on_test_id"

  create_table "solutions", :force => true do |t|
    t.integer  "problem_id",                            :null => false
    t.integer  "user_id",                               :null => false
    t.float    "percent",           :default => 0.0,    :null => false
    t.float    "time",              :default => 5000.0, :null => false
    t.datetime "created_at",                            :null => false
    t.integer  "contest_id"
    t.string   "source_file_name"
    t.datetime "source_updated_at"
    t.float    "point",             :default => 0.0
    t.text     "junk"
    t.integer  "solved_in"
    t.string   "state"
    t.integer  "source_file_size"
    t.string   "language",          :default => "",     :null => false
  end

  add_index "solutions", ["contest_id"], :name => "index_solutions_on_contest_id"
  add_index "solutions", ["problem_id"], :name => "index_solutions_on_problem_id"
  add_index "solutions", ["user_id"], :name => "index_solutions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login",                                                :null => false
    t.string   "email",                                                :null => false
    t.string   "crypted_password"
    t.string   "salt",                :limit => 40
    t.datetime "created_at"
    t.string   "school"
    t.boolean  "admin",                             :default => false
    t.boolean  "judge",                             :default => false
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.string   "password_salt"
    t.integer  "solutions_count",                   :default => 0
    t.float    "points",                            :default => 0.0
    t.boolean  "mailed",                            :default => false
    t.string   "web"
    t.string   "twitter"
    t.boolean  "notify_new_contests",               :default => true
  end

  add_index "users", ["login"], :name => "index_users_on_login"

end
