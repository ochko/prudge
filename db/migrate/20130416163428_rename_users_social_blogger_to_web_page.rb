class RenameUsersSocialBloggerToWebPage < ActiveRecord::Migration
  def up
    rename_column :users, :social_blogger, :web

    conn = ActiveRecord::Base.connection
    conn.select_rows("select id, web_page from users where web_page is not null and web_page != ''").each do |row|
      id, blogger = *row
    
      next if blogger =~ /^http/
    
      web =
        if blogger.index('@')
          nil
        elsif blogger.index('.').nil?
          "http://#{blogger}.blogspot.com"
        else
          "http://#{blogger}"
        end
      
      conn.update "update users set web = '#{web}' where id = #{id}"
    end
  end

  def down
    rename_column :users, :web, :social_blogger
  end
end
