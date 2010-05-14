class AddHiddenToResults < ActiveRecord::Migration
  def self.up
    add_column :results, :hidden, :boolean, :default => true
    Result.reset_column_information
    Result.all.each do |result|
      if result.test
        result.update_attribute(:hidden, result.test.hidden) 
      else
        result.destroy
      end
    end
  end

  def self.down
    remove_column :results, :hidden
  end
end
