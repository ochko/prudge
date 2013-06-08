class PaperclipResultAttachments < ActiveRecord::Migration
  def up
    Result.uniq.pluck(:solution_id).each do |id|
      next unless solution = Solution.find_by_id(id)
      solution.results.each do |result|
        take_out(solution, result)
      end
    end
  end

  def down
    Result.all.each do |result|
      bring_in(result)
    end
  end

  def take_out(solution, result)
    dir = Rails.root.join('judge', 'results',
                          solution.user_id.to_s,
                          solution.problem_id.to_s,
                          solution.id.to_s)

    if !result.record_output.blank? && result.output_file_name.nil?
      FileUtils.mkpath dir
      output = dir.join("#{result.id}.output")
      File.open(output,'w') { |file| file.write result.record_output }
      result.output = File.open(output)
    end

    if !result.record_diff.blank? && result.diff_file_name.nil?
      FileUtils.mkpath dir
      diff = dir.join("#{result.id}.diff")
      File.open(diff,'w') { |file| file.write result.record_diff }
      result.diff = File.open(diff)
    end

    result.save!
  end

  def bring_in(result)
    result[:record_output] = File.read(result.output.path)
    result[:record_diff] = File.read(result.diff.path)
    result.save!
  end

end
