class DropLanguages < ActiveRecord::Migration
  def up
    remove_column :solutions, :language_id
    drop_table :languages
  end

  def down
    create_table "languages" do |t|
      t.string  "name",        :limit => 15,                :null => false
      t.string  "compiler",                                 :null => false
      t.string  "runner",                                   :null => false
      t.integer "mem_req",                   :default => 0, :null => false
      t.integer "time_req",                  :default => 0, :null => false
      t.string  "description"
      t.integer "nproc",                     :default => 0
    end

    YAML.load_file(Rails.root.join('config', 'languages.yml')).each_with_index do |options, id|
      name =  options['name']
      execute "update solutions set language_id = #{id} where language = '#{name.downcase}'"
    end


    add_column :solutions, :language_id, :integer
  end
end
