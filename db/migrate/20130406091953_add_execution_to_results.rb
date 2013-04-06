class AddExecutionToResults < ActiveRecord::Migration
  def self.up
    add_column :results, :execution, :integer, :default => 0, :null => false

    conn = ActiveRecord::Base.connection

    conn.select_all("select id, status from results").each do |record|
      record.symbolize_keys!
      next if record[:status].nil?
      usage = Usage.new(record[:status].strip)
      conn.update("update results set execution = #{usage.state} where id = #{record[:id]}")
    end
  end

  def self.down
    remove_column :results, :execution
  end
end
