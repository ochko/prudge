class DefaultsOnResults < ActiveRecord::Migration
  def self.up
    change_column :results, :status, :string, :default => '', :null => false
    change_column :results, :output, :text, :default => '', :null => false
  end

  def self.down
    change_column :results, :status, :string, :null => false
    change_column :results, :output, :text, :null => false
  end
end
