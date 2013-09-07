class ContestOpeningMailJob < BaseJob
  @queue = :mail

  def self.perform(id)
    contest = Contest.find id

    User.where(notify_new_contests: true).each do |user|
      next unless user.notify_new_contests?
      next unless user.email_valid?

      Notifier.new_contest(user, contest).deliver
    end
  end
end
