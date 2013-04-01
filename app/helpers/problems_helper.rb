# -*- coding: utf-8 -*-
module ProblemsHelper
  def solved_or_not(state)
    if state == 'passed'
      image_tag('ok.png', :title => "Бодчихсон")
    elsif state == 'failed'
      image_tag('ng.png', :title => "Бодож чадаагүй")
    else
      ''
    end
  end
end
