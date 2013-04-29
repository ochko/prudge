class RemoveUsersUploadedAt < ActiveRecord::Migration
  def up
    remove_column :users, :uploaded_at
  end

  def down
    add_column :users, :uploaded_at, :datetime
    ActiveRecord::Base.connection.select_rows("select user_id, max(source_updated_at) from solutions group by user_id").each do |row|
      user_id, uploaded_at = *row
      execute "update users set uploaded_at = '#{uploaded_at}' where id = #{user_id}"
    end
  end
end
