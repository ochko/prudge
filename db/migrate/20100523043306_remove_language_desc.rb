class RemoveLanguageDesc < ActiveRecord::Migration
  def self.up
    remove_column :languages, :description
  end

  def self.down
    add_column :languages, :description, :string
  end
end
