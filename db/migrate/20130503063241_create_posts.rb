class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.boolean :delta, :default => true
      t.integer :author_id, :null => false
      t.string :category, :null => false
      t.string :title, :null => false
      t.text :body, :null => false

      t.timestamps
    end
  end
end
