class ContestUpdateTwitJob < ContestTwitBaseJob
  def work(id)
    contest = Contest.find(id)
    Twitter.update(post_for :update_announcement, contest)
  end
end
