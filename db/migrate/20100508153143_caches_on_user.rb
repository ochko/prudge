class CachesOnUser < ActiveRecord::Migration
  def self.up
    add_column :users, :solutions_count, :integer, :default => 0
    add_column :users, :points, :float, :default => 0.0
    add_column :users, :average, :float, :default => 0.0
    add_column :users, :uploaded_at, :datetime

    User.reset_column_information
    User.all.each do |user|
      user.collect_caches!
    end
    
  end

  def self.down
    remove_column :users, :solutions_count
    remove_column :users, :points
    remove_column :users, :average
    remove_column :users, :uploaded_at
  end
end
