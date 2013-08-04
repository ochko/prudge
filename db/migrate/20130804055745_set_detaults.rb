class SetDetaults < ActiveRecord::Migration
  def up
    change_column_default :solutions, :percent, 0
    change_column_default :solutions, :time, 0
    change_column_default :solutions, :point, 0
  end

  def down
  end
end
