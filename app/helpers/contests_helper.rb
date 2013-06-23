# -*- coding: utf-8 -*-
module ContestsHelper
  def standing(num)
    medal = medal_name(num)

    return num unless medal

    content_tag(:i, nil, :class => "icon-trophy #{medal}", :title=> medal)
  end

  def medal_name(num)
    %w(nothing gold silver bronze)[num]
  end

  def show_status(contest)
    if Time.now() < contest.start
      "Эхлэхэд #{distance_of_time_in_words_to_now contest.start} үлдлээ"
    elsif Time.now() > contest.start &&
        Time.now() < contest.end
      "Дуусахад #{distance_of_time_in_words_to_now contest.end} үлдлээ"
    else
      "Тэмцээн дууссан"
    end
  end

  def medal_list(standings)
    counts = {}
    standings.each do |standing|
      next if standing.rank > 3 || standing.rank < 1
      counts[standing.rank] ||= 0
      counts[standing.rank] += 1
    end
    counts
  end

  def options_for_levels
    [0,1,2,4,8,16,32,64,128].map do |level|
      [t(level.to_s, :scope => :rank), level]
    end
  end
end
