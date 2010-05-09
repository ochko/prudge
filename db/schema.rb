# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100509180528) do

  create_table "attachments", :force => true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type", :limit => 15, :null => false
    t.integer  "size"
    t.string   "content_type",    :limit => 31, :null => false
    t.string   "filename",        :limit => 63, :null => false
    t.string   "notes"
    t.datetime "created_at",                    :null => false
  end

  add_index "attachments", ["attachable_type"], :name => "index_attachments_on_attachable_type"

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
    t.string   "name",                                          :null => false
    t.datetime "start",                                         :null => false
    t.datetime "end",                                           :null => false
    t.text     "description",                                   :null => false
    t.string   "category",    :limit => 15, :default => "none"
  end

  create_table "homeworks", :force => true do |t|
    t.integer "lesson_id",  :null => false
    t.integer "problem_id", :null => false
  end

  add_index "homeworks", ["lesson_id"], :name => "index_homeworks_on_lesson_id"
  add_index "homeworks", ["problem_id"], :name => "index_homeworks_on_problem_id"

  create_table "languages", :force => true do |t|
    t.string  "name",        :limit => 15,                :null => false
    t.text    "description",                              :null => false
    t.string  "compiler",                                 :null => false
    t.string  "runner",                                   :null => false
    t.integer "mem_req",                   :default => 0, :null => false
    t.integer "time_req",                  :default => 0, :null => false
  end

  create_table "lessons", :force => true do |t|
    t.integer  "author_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title",      :null => false
    t.text     "text",       :null => false
    t.string   "tags",       :null => false
  end

  add_index "lessons", ["author_id"], :name => "index_lessons_on_author_id"

  create_table "pages", :force => true do |t|
    t.string   "category",   :limit => 15, :null => false
    t.string   "title",                    :null => false
    t.text     "content",                  :null => false
    t.string   "tags",                     :null => false
    t.datetime "created_at",               :null => false
    t.integer  "user_id",                  :null => false
  end

  add_index "pages", ["user_id"], :name => "index_pages_on_user_id"

  create_table "photos", :force => true do |t|
    t.integer "user_id"
    t.integer "size",                       :null => false
    t.string  "content_type", :limit => 31, :null => false
    t.string  "filename",     :limit => 63, :null => false
    t.integer "height",                     :null => false
    t.integer "width",                      :null => false
    t.integer "parent_id"
    t.string  "thumbnail",    :limit => 15
  end

  create_table "problem_languages", :force => true do |t|
    t.integer "problem_id",  :null => false
    t.integer "language_id", :null => false
  end

  add_index "problem_languages", ["language_id"], :name => "index_problem_languages_on_language_id"
  add_index "problem_languages", ["problem_id"], :name => "index_problem_languages_on_problem_id"

  create_table "problem_tests", :force => true do |t|
    t.integer "problem_id",                                       :null => false
    t.text    "input",      :limit => 16777215,                   :null => false
    t.text    "output",     :limit => 16777215,                   :null => false
    t.boolean "hidden",                         :default => true, :null => false
  end

  add_index "problem_tests", ["problem_id"], :name => "index_problem_tests_on_problem_id"

  create_table "problems", :force => true do |t|
    t.integer  "user_id",                                   :null => false
    t.integer  "contest_id"
    t.integer  "level",                     :default => 1,  :null => false
    t.integer  "time",                      :default => 1,  :null => false
    t.integer  "memory",                    :default => 64, :null => false
    t.string   "name",       :limit => 128,                 :null => false
    t.text     "text",                                      :null => false
    t.datetime "created_at",                                :null => false
    t.string   "source"
  end

  add_index "problems", ["contest_id"], :name => "index_problems_on_contest_id"
  add_index "problems", ["user_id"], :name => "index_problems_on_user_id"

  create_table "results", :force => true do |t|
    t.integer "solution_id",                    :null => false
    t.integer "test_id",                        :null => false
    t.boolean "matched",     :default => false, :null => false
    t.string  "status",      :default => "",    :null => false
    t.integer "time",        :default => 3,     :null => false
    t.integer "memory",      :default => 64,    :null => false
    t.text    "output",                         :null => false
    t.boolean "hidden",      :default => true
  end

  add_index "results", ["solution_id"], :name => "index_results_on_solution_id"
  add_index "results", ["test_id"], :name => "index_results_on_test_id"

  create_table "role_users", :force => true do |t|
    t.integer "role_id", :null => false
    t.integer "user_id", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string "title", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data",       :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "new_index1"
  add_index "sessions", ["updated_at"], :name => "new_index2"

  create_table "solutions", :force => true do |t|
    t.integer  "problem_id",                              :null => false
    t.integer  "user_id",                                 :null => false
    t.integer  "language_id",                             :null => false
    t.boolean  "checked",             :default => false,  :null => false
    t.boolean  "correct",             :default => false,  :null => false
    t.float    "percent",             :default => 0.0,    :null => false
    t.float    "time",                :default => 5000.0, :null => false
    t.datetime "created_at",                              :null => false
    t.boolean  "locked",              :default => false,  :null => false
    t.boolean  "isbest",              :default => true,   :null => false
    t.boolean  "invalidated",         :default => false
    t.integer  "contest_id"
    t.string   "source_file_name"
    t.string   "source_content_type"
    t.integer  "source_file_size"
    t.datetime "uploaded_at"
    t.float    "point"
  end

  add_index "solutions", ["contest_id"], :name => "index_solutions_on_contest_id"
  add_index "solutions", ["problem_id"], :name => "index_solutions_on_problem_id"
  add_index "solutions", ["user_id"], :name => "index_solutions_on_user_id"

  create_table "topics", :force => true do |t|
    t.datetime "created_at",  :null => false
    t.string   "title",       :null => false
    t.text     "description", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       :limit => 40
    t.string   "school_name"
    t.text     "self_intro"
    t.integer  "solutions_count",                         :default => 0
    t.float    "points",                                  :default => 0.0
    t.float    "average",                                 :default => 0.0
    t.datetime "uploaded_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login"

end
