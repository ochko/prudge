class ContestOpeningTwitJob < ContestTwitBaseJob
  @queue = :twit

  def work(id)
    contest = Contest.find(id)
    Twitter.update(post_for :opening_announcement, contest)
  end
end
