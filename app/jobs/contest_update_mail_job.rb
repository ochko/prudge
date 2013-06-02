class ContestUpdateMailJob
  def work(id)
    contest = Contest.find id

    contest.watchers.each do |user|
      Notifier.contest_update(user, contest).deliver
    end
  end
end
