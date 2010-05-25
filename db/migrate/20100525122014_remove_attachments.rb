class RemoveAttachments < ActiveRecord::Migration
  def self.up
    drop_table :attachments
  end

  def self.down
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
    
  end
end
