class NullifyResultOutputsForCorrect < ActiveRecord::Migration
  # no need to keep output of matched results
  def self.up
    execute "update results set output = NULL where matched = 1"
  end

  def self.down
    # no need
  end
end
