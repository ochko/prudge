class MoveFiles < ActiveRecord::Migration
  def self.up
    add_column :solutions, :contest_id, :integer
    rename_column :solutions, :avg_time, :time
    add_column :solutions, :source_file_name,    :string
    add_column :solutions, :source_content_type, :string
    add_column :solutions, :source_file_size,    :integer
    add_column :solutions, :uploaded_at,         :datetime
    
    Solution.reset_column_information
    
    Solution.all.each do |solution| 
      if File.exists?(solution.public_filename) && solution.user
        contest_id = if solution.problem.contest &&
                         (solution.updated_at < solution.problem.contest.end)
                       solution.problem.contest_id 
                     else 
                       nil
                     end
        solution.source_file_name = solution.filename
        solution.source_content_type = solution.content_type
        solution.source_file_size = solution.size
        solution.uploaded_at = solution.updated_at
        solution.contest_id = contest_id
        solution.send(:update_without_callbacks)

        FileUtils.mkpath solution.dir
        FileUtils.cp(solution.public_filename , 
                     "#{solution.dir}/#{solution.id}.code")
      else
        solution.results.delete
        solution.delete
      end
    end

    remove_column :solutions, :filename
    remove_column :solutions, :content_type
    remove_column :solutions, :size
    remove_column :solutions, :updated_at

    add_index :solutions, :contest_id
  end

  def self.down
    remove_column :solutions, :source_file_name
    remove_column :solutions, :source_content_type
    remove_column :solutions, :source_file_size
    remove_column :solutions, :uploaded_at
    remove_column :solutions, :contest_id

    add_column :solutions, :filename,     :string
    add_column :solutions, :content_type, :string
    add_column :solutions, :size,         :integer
    add_column :solutions, :updated_at,   :datetime
    rename_column :solutions, :time, :avg_time

    Solution.reset_column_information

    Solution.all.each do |solution| 
      solution.
        update_attributes(:filename => solution.source_file_name,
                          :content_type => solution.source_content_type,
                          :size => solution.source_file_size,
                          :updated_at => solution.uploaded_at )
    end
  end

end
