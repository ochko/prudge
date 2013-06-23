class CreateParticipants < ActiveRecord::Migration
  def up
    create_table :participants do |t|
      t.integer :contest_id , :null => false
      t.integer :user_id    , :null => false
      t.integer :rank
      t.float   :points     , :default => 0.0
    end

    connection.select_values("SELECT id FROM contests").each do |contest_id|
      rank, point, time = 0, 0.0, 0.0
      connection.select_rows("SELECT user_id, sum(point) AS point, sum(solved_in) AS time FROM solutions WHERE contest_id = #{contest_id} GROUP BY user_id ORDER BY point DESC, time ASC").each do |row|
        user_id, user_point, user_time = row[0], row[1].to_f, row[2].to_f

        if (point != user_point) || (user_time - time > 0.1)
          point = user_point
          rank += 1
        end

        values = [contest_id, user_id, rank, user_point].map{|v| connection.quote v}.join(', ')
        connection.execute("INSERT INTO participants(contest_id, user_id, rank, points) VALUES(#{values})")
      end
    end

    add_index :participants, :contest_id
    add_index :participants, :user_id
    add_index :participants, [:contest_id, :user_id], :unique => true
  end

  def down
    drop_table :participants
  end
end
