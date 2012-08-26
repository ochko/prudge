class AddSocialMedias < ActiveRecord::Migration
  def self.up
    add_column :users, :social_blogger, :string
    add_column :users, :social_facebook, :string
    add_column :users, :social_google, :string
    add_column :users, :social_hi5, :string
    add_column :users, :social_twitter, :string
    add_column :users, :social_yahoo, :string
  end

  def self.down
    remove_column :users, :social_blogger
    remove_column :users, :social_facebook
    remove_column :users, :social_google
    remove_column :users, :social_hi5
    remove_column :users, :social_twitter
    remove_column :users, :social_yahoo
  end
end
