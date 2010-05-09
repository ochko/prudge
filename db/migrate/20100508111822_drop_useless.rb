class DropUseless < ActiveRecord::Migration
  def self.up
    drop_table :banners
    drop_table :contest_types
    drop_table :fulfillment_files
    drop_table :fulfillments
    drop_table :poll_choices
    drop_table :polls
    drop_table :prizes
    drop_table :problem_types
    drop_table :question_answers
    drop_table :ratings
    drop_table :tasks
    drop_table :sponsors
    
    drop_table :contents
    drop_table :courses
    drop_table :groups
    drop_table :memberships
    
  end

  def self.down
    create_table "banners", :force => true do |t|
      t.text    "contact",                                       :null => false
      t.integer "erembe",                     :default => 0,     :null => false
      t.boolean "enabled",                    :default => false, :null => false
      t.string  "address",                                       :null => false
      t.integer "clicks",                     :default => 0,     :null => false
      t.integer "size",                                          :null => false
      t.string  "content_type", :limit => 31,                    :null => false
      t.string  "filename",     :limit => 63,                    :null => false
      t.integer "height",                                        :null => false
      t.integer "width",                                         :null => false
      t.integer "parent_id"
      t.string  "thumbnail",    :limit => 15
    end
  end
  
  create_table "contest_types", :force => true do |t|
    t.string "name",        :null => false
    t.text   "description", :null => false
  end

  create_table "fulfillment_files", :force => true do |t|
    t.integer  "fulfillment_id"
    t.datetime "created_at",                   :null => false
    t.integer  "size",                         :null => false
    t.string   "content_type",   :limit => 31, :null => false
    t.string   "filename",       :limit => 63, :null => false
    t.integer  "height",                       :null => false
    t.integer  "width",                        :null => false
    t.integer  "parent_id"
    t.string   "thumbnail",      :limit => 15, :null => false
  end

  create_table "fulfillments", :force => true do |t|
    t.integer  "task_id",                       :null => false
    t.integer  "user_id",                       :null => false
    t.text     "outline",                       :null => false
    t.datetime "created_at",                    :null => false
    t.integer  "earnings",   :default => 0,     :null => false
    t.boolean  "payd",       :default => false, :null => false
    t.text     "comment"
  end

  create_table "poll_choices", :force => true do |t|
    t.integer "poll_id",                :null => false
    t.string  "answer",                 :null => false
    t.integer "counter", :default => 0, :null => false
  end

  create_table "polls", :force => true do |t|
    t.boolean "active",   :default => false, :null => false
    t.string  "question",                    :null => false
  end

  create_table "prizes", :force => true do |t|
    t.string "name",        :null => false
    t.text   "description", :null => false
  end

  create_table "problem_types", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "question_answers", :force => true do |t|
    t.integer  "asker_id",    :null => false
    t.integer  "answerer_id"
    t.text     "question",    :null => false
    t.text     "answer"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "ratings", :force => true do |t|
    t.integer  "rating",                      :default => 0, :null => false
    t.datetime "created_at",                                 :null => false
    t.string   "rateable_type", :limit => 15,                :null => false
    t.integer  "rateable_id",                 :default => 0, :null => false
    t.integer  "user_id",                     :default => 0, :null => false
  end
  
  create_table "sponsors", :force => true do |t|
    t.string "name",        :null => false
    t.text   "description", :null => false
  end

  create_table "tasks", :force => true do |t|
    t.integer  "subscriber_id",                                   :null => false
    t.integer  "price",                                           :null => false
    t.datetime "deadline",                                        :null => false
    t.string   "subject",       :limit => 555,                    :null => false
    t.text     "outline",                                         :null => false
    t.string   "technology",                   :default => "any", :null => false
    t.text     "requirements",                                    :null => false
    t.text     "deliverables",                                    :null => false
    t.string   "status",        :limit => 15,  :default => "new", :null => false
  end

  create_table "contents", :force => true do |t|
    t.integer "course_id", :limit => 11, :null => false
    t.integer "lesson_id", :limit => 11, :null => false
  end

  add_index "contents", ["lesson_id"]
  add_index "contents", ["course_id"]

  create_table "courses", :force => true do |t|
    t.string  "name",                      :default => "", :null => false
    t.text    "description",                               :null => false
    t.integer "teacher_id",  :limit => 11,                 :null => false
  end

  add_index "courses", ["teacher_id"]

  create_table "groups", :force => true do |t|
    t.string   "name",        :limit => 200, :default => "",    :null => false
    t.datetime "created_at",                                    :null => false
    t.integer  "course_id",   :limit => 11,                     :null => false
    t.boolean  "isopen",                     :default => false, :null => false
    t.text     "description",                                   :null => false
  end

  add_index "groups", ["course_id"]

  create_table "memberships", :force => true do |t|
    t.integer "group_id", :limit => 11,                :null => false
    t.integer "user_id",  :limit => 11,                :null => false
    t.integer "status",   :limit => 11, :default => 0, :null => false
  end

  add_index "memberships", ["group_id"]
  add_index "memberships", ["user_id"]
end
