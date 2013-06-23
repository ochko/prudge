# -*- coding: utf-8 -*-
module ContestsHelper
  def standing(num)
    medal = medal_name(num)

    return num unless medal

    content_tag(:i, nil, :class => "icon-trophy #{medal}", :title=> medal)
  end

  def medal_name(num)
    %w(_ gold silver bronze)[num]
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

  def medal_counts(user)
    user.standings.where('rank <= 3').group('rank').select('rank, count(id) as count').sort_by(&:rank)
  end
end
