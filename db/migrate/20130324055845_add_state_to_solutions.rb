class AddStateToSolutions < ActiveRecord::Migration
  def self.up
    add_column :solutions, :state, :string
  end

  def self.down
    remove_column :solutions, :state
  end
end
