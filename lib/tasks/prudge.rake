namespace :prudge do
  desc "Send release notification email to all users"
  task :release => :environment do
    User.all.each do |user|
      next unless user.email_valid?
      Notifier.release_notification(user).deliver
    end
  end

  namespace :reprocess do
    desc "Update paperclip attachment meta data"
    task :solutions => :environment do
      Solution.pluck(:id).each do |id|
        solution = Solution.find(id)
        source = solution.source
        source.reprocess! if source.exists?
      end
    end
  end
end
