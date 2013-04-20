# -*- coding: utf-8 -*-
module PagesHelper
  def show_category(category)
    if category == 'news'
      "Мэдээ"
    elsif category == 'help'
      "Тусламж"
    elsif category == 'rule'
      "Дүрэм"
    else
      "Хуудас"
    end
  end

  def topic_title_for(param_type)
    if !param_type
      'Хэлэлцүүлгүүд'
    elsif param_type.eql?('contest')
      'Тэмцээний хэлэлцүүлгүүд'
    elsif param_type.eql?('problem')
      'Бодлогын хэлэлцүүлгүүд'
    elsif param_type.eql?('lesson')
      'Хичээлийн хэлэлцүүлгүүд'
    else
      'Хэлэлцүүлгүүд'
    end
  end
end
