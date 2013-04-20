# -*- coding: utf-8 -*-
module ContestsHelper
  def standing(num)
    if num > 3
      return num
    end
    if num == 1
      content_tag(:i, nil, :class => 'icon-trophy gold', :title=> 'Gold')
    elsif num == 2
      content_tag(:i, nil, :class => 'icon-trophy silver', :title=> 'Silver')
    elsif num == 3
      content_tag(:i, nil, :class => 'icon-trophy bronze', :title=> 'Bronze')
    end
  end

  def show_status(contest)
    if Time.now() < contest.start
      "Эхлэхэд #{distance_of_time_in_words_to_now contest.start} үлдлээ"
    elsif Time.now() > contest.start &&
        Time.now() < contest.end
      "Дуусахад #{distance_of_time_in_words_to_now contest.end} үлдлээ"
    else
      "Дууссан"
    end
  end

  def medal_list(standings)
    list =[]
    medal_color = 1
    standings.sort{|a,b| a[1]<=>b[1]}.each do |c, s|
      if s < 4
        if medal_color != s
          medal_color = s
          list << '<br />'
        end
        list << link_to(standing(s),c)
      end
    end
    return list.join(' ')
  end
end
