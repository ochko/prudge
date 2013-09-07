class ContestOpeningTwitJob < ContestTwitBaseJob
  @queue = :twit

  def self.perform(id)
    contest = Contest.find(id)
    Twitter.update(post_for :opening_announcement, contest)
  end
end
