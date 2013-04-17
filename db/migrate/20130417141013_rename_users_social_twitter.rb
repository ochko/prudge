class RenameUsersSocialTwitter < ActiveRecord::Migration
  def up
    rename_column :users, :social_twitter, :twitter

    conn = ActiveRecord::Base.connection
    conn.select_rows("select id, twitter from users where twitter is not null and twitter != ''").each do |row|
      id, tw = *row
      
      next if tw =~ /^@/ # correctly formatted
      
      twitter =
        if tw.index('@')
          nil # looks like email, not twitter handle
        else
          "@"+tw.split('/').last
        end
      
      conn.update "update users set twitter = '#{twitter}' where id = #{id}"
    end
  end

  def down
    rename_column :users, :twitter, :social_twitter
  end
end
