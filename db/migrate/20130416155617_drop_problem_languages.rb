class DropProblemLanguages < ActiveRecord::Migration
  def up
    drop_table "problem_languages"
  end

  def down
    create_table "problem_languages" do |t|
      t.integer "problem_id",  :null => false
      t.integer "language_id", :null => false
    end

    add_index "problem_languages", ["language_id"], :name => "index_problem_languages_on_language_id"
    add_index "problem_languages", ["problem_id"], :name => "index_problem_languages_on_problem_id"
  end
end
