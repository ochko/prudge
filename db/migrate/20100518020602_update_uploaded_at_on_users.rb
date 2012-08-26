class UpdateUploadedAtOnUsers < ActiveRecord::Migration
  def self.up
    Solution.find(:all, :select => 'user_id, max(uploaded_at) as uploaded_at', :group => 'user_id').each do |solution|
      solution.user.update_attribute(:uploaded_at, solution.uploaded_at)
    end
  end

  def self.down
  end
end
