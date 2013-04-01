class RemoveSolutionsFlagColumns < ActiveRecord::Migration
  def self.up
    execute("update solutions set state = 'defunct' where nocompile = 1")
    execute("update solutions set state = 'passed' where checked = 1 and correct = 1")
    execute("update solutions set state = 'failed' where checked = 1 and correct = 0")
    execute("update solutions set state = 'locked' where locked = 1")
    execute("update solutions set state = 'updated' where state is null")

    remove_column 'solutions', 'nocompile'
    remove_column 'solutions', 'checked'
    remove_column 'solutions', 'correct'
    remove_column 'solutions', 'locked'
  end

  def self.down
    add_column 'solutions', 'nocompile', :boolean, :default => false
    add_column 'solutions', 'checked', :boolean, :default => false, :null => false
    add_column 'solutions', 'correct', :boolean, :default => false, :null => false
    add_column 'solutions', 'locked', :boolean, :default => false, :null => false
    # Can't restore flags from state in sql.
  end
end
