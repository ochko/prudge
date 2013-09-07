class ContestUpdateMailJob < BaseJob
  @queue = :mail

  def self.perform(id)
    contest = Contest.find id

    contest.watchers.each do |user|
      Notifier.contest_update(user, contest).deliver
    end
  end
end
