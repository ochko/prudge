class AddUserRoles < ActiveRecord::Migration
  def self.up
    %w[admin judge].each do |role|
      add_column :users, role, :boolean, :default => false
      User.reset_column_information
      Role.find_by_title(role.capitalize).users.each do |user|
        user.update_attribute(role, true)
      end
    end
  end

  def self.down
    %w[admin judge].each do |role|
      remove_column :users, role
    end
  end
end
