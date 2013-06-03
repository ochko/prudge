class DropOpenidTables < ActiveRecord::Migration
  def up
    remove_column :users, :openid_identifier

    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
  end

  def down

    create_table "open_id_authentication_associations" do |t|
      t.integer "issued"
      t.integer "lifetime"
      t.string  "handle"
      t.string  "assoc_type"
      t.binary  "server_url"
      t.binary  "secret"
    end

    create_table "open_id_authentication_nonces" do |t|
      t.integer "timestamp",  :null => false
      t.string  "server_url"
      t.string  "salt",       :null => false
    end

    add_column :users, :openid_identifier, :string
    add_index :users, ["openid_identifier"], :name => "index_users_on_openid_identifier"
  end
end
