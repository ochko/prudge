class AddDescriptionToLanguages < ActiveRecord::Migration
  def self.up
    add_column :languages, :description, :string
  end

  def self.down
    remove_column :languages, :description
  end
end
