class SanitizeLogins < ActiveRecord::Migration
  def self.up
    User.
      find(:all, :conditions => "solutions_count = 0").
      select{|user| !user.uploaded_at.nil?}.
      each do |user|
        login = user.login.delete("*$/?[]_|#\"=()<>, -")
        login << "user#{user.id}" if login.size < 3
        user.update_attribute(:login, login)
      end
  end

  def self.down
    #Sorry, cannot undo!
  end
end
