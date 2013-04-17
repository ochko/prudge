class RemoveUsersSocialFacebook < ActiveRecord::Migration
  def up
    conn = ActiveRecord::Base.connection
    conn.select_rows("select id, web, social_facebook from users where social_facebook is not null and social_facebook != ''").each do |row|
      id, web, fb = *row
      
      next if web =~ /^http/
      
      web =
        if fb.index('@') || fb.index(' ')
          nil
        elsif fb =~ /^http/
          fb
        elsif fb.index('.').nil?
          "http://www.facebook.com/#{fb}"
        elsif fb =~ /^[a-z0-9A-Z\.]+$/
          "http://#{fb}"
        else
          nil
        end
      
      conn.update "update users set web = '#{web}' where id = #{id}"
    end

    remove_column :users, :social_facebook
  end

  def down
    add_column :users, :social_facebook, :string
  end
end
