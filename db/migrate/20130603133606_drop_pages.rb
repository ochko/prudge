class DropPages < ActiveRecord::Migration
  def up
    drop_table :pages
  end

  def down
    create_table "pages" do |t|
      t.string   "category",   :limit => 15,                   :null => false
      t.string   "title",                                      :null => false
      t.text     "content",                                    :null => false
      t.datetime "created_at",                                 :null => false
      t.integer  "user_id",                                    :null => false
      t.boolean  "delta",                    :default => true, :null => false
    end

    add_index "pages", ["user_id"], :name => "index_pages_on_user_id"
  end
end
