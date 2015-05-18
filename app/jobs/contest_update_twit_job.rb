class ContestUpdateTwitJob < ContestTwitBaseJob
  @queue = :twit

  def self.perform(id)
    contest = Contest.find(id)
    client.update(post_for :update_announcement, contest)
  end
end
