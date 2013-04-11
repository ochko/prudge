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
end
