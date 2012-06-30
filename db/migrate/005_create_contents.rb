class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
    end
  end

  def self.down
    drop_table :contents
  end
end
