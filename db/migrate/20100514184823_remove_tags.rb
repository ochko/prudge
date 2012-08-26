class RemoveTags < ActiveRecord::Migration
  def self.up
    remove_column :lessons, :tags
    remove_column :pages, :tags
  end

  def self.down
    add_column :lessons, :tags, :string
    add_column :pages, :tags, :string
  end
end
