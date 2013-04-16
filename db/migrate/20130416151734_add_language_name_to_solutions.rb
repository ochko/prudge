class AddLanguageNameToSolutions < ActiveRecord::Migration
  def up
    add_column :solutions, :language, :string, :null => false, :default => ''

    ActiveRecord::Base.connection.select_rows("select id, name from languages").each do |row|
      id, name = *row
      execute "update solutions set language = '#{name.downcase}' where language_id = #{id}"
    end
  end
  def down
    remove_column :solutions, :language
  end
end
