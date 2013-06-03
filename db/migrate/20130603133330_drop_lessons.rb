class DropLessons < ActiveRecord::Migration
  def up
    drop_table :lessons
  end

  def down
    create_table "lessons" do |t|
      t.integer  "author_id",                        :null => false
      t.datetime "created_at",                       :null => false
      t.datetime "updated_at",                       :null => false
      t.string   "title",                            :null => false
      t.text     "text",                             :null => false
      t.boolean  "delta",          :default => true, :null => false
      t.integer  "comments_count", :default => 0
      t.datetime "commented_at"
    end

    add_index "lessons", ["author_id"], :name => "index_lessons_on_author_id"
  end
end
