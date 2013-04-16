# -*- coding: utf-8 -*-
class ContestObserver < ActiveRecord::Observer
  def before_save(contest)
    return unless contest.time_changed?
    contest.problems.each do |problem|
      problem.update_active_interval
      problem.save!
    end
  end
  
  def after_create(contest)
    Twitit.update opening_announcement(contest)

    User.active.each do |user|
      user.delay.notify_new_contest(contest)
    end
  end

  def after_save(contest)
    return unless contest.time_changed?

    Twitit.update update_announcement(contest)

    contest.watchers.each do |watcher|
      watcher.delay.notify_contest_update(contest)
    end
  end

  private

  def opening_announcement(contest)
    "Шинэ тэмцээн зарлагдаа: '#{contest.name}'. #{contest_url(contest)}"
  end

  def update_announcement(contest)
    "Тэмцээний хугацаа өөрчлөгдөв: '#{contest.name}'. #{contest_url(contest)} (#{contest.start} -> #{contest.end})"
  end

  def contest_url(contest)
    Rails.application.routes.url_helpers.contest_url(contest)
  end
end
