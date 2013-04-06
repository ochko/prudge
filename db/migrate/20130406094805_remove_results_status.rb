class RemoveResultsStatus < ActiveRecord::Migration
  def self.up
    remove_column :results, :status
  end

  def self.down
    add_column :results, :status, :string, :default => "", :null => false
    # Actually it need more work.
    # Need to set these text in status column
    #---------------------------------------
    # 0     => ''
    # 2**0  => 'OK'
    # 2**1  => 'Time Limit Exceeded'
    # 2**2  => 'Memory Limit Exceeded'
    # 2**3  => 'Output Limit Exceeded'
    # 2**4  => 'Invalid Function'
    # 2**5  => 'Command exited with non-zero'
    # 2**6  => 'Command terminated by signal'
    # 2**16 => 'Internal Error'
    #---------------------------------------
  end
end
