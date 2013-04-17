class UpdateUserSocials < ActiveRecord::Migration
  def up
    remove_column :users, :social_hi5
    remove_column :users, :social_yahoo
    remove_column :users, :social_google
  end

  def down
    add_column :users, :social_hi5, :string
    add_column :users, :social_yahoo, :string
    add_column :users, :social_google, :string
  end
end
