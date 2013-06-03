class DropSessions < ActiveRecord::Migration
  def up
    drop_table :sessions
  end

  def down
    create_table "sessions", :force => true do |t|
      t.string   "session_id", :null => false
      t.text     "data",       :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "sessions", ["session_id"], :name => "new_index1"
    add_index "sessions", ["updated_at"], :name => "new_index2"
  end
end
