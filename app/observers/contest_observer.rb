# -*- coding: utf-8 -*-
class ContestObserver < ActiveRecord::Observer
  def after_create(contest)
    Resque.enqueue ContestOpeningMailJob, contest.id
    Resque.enqueue ContestOpeningTwitJob, contest.id
  end

  def after_save(contest)
    return unless contest.time_changed?

    contest.problems.each do |problem|
      problem.update_active_interval
      problem.save!
    end

    Resque.enqueue ContestUpdateTwitJob, contest.id
    Resque.enqueue ContestUpdateMailJob, contest.id
  end
end
