class DropTopics < ActiveRecord::Migration
  def up
    drop_table :topics
  end

  def down
    create_table "topics" do |t|
      t.datetime "created_at",                       :null => false
      t.string   "title",                            :null => false
      t.text     "description",                      :null => false
      t.boolean  "delta",          :default => true, :null => false
      t.integer  "comments_count", :default => 0
      t.datetime "commented_at"
    end
  end
end
