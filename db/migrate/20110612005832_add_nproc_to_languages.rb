class AddNprocToLanguages < ActiveRecord::Migration
  def self.up
    add_column :languages, :nproc, :integer, :default => 0
  end

  def self.down
    remove_column :languages, :nproc
  end
end
