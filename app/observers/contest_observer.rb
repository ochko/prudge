class ContestObserver < ActiveRecord::Observer
  def before_save(contest)
    return unless contest.time_changed?
    contest.problems.each do |problem|
      problem.update_active_interval
      problem.save!
    end
  end
  
  def after_create(contest)
    Twitit.update create_announcement
    User.active.each do |user|
      user.delay.notify_new_contest(contest)
    end
  end

  def after_save(contest)
    return unless contest.time_changed?

    Twitit.update update_announcement
    contest.watchers.each do |watcher|
      watcher.delay.notify_contest_update(contest)
    end
  end
end
