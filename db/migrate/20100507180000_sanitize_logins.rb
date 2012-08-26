class SanitizeLogins < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      login = user.login.delete("*$/?[]_|#\"=()<>, -")
      login << "user#{user.id}" if login.size < 3
      user.update_attribute(:login, login)
    end
  end

  def self.down
    #Sorry, cannot undo!
  end
end
