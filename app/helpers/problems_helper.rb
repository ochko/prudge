module ProblemsHelper
  def solved_or_not(correct)
    if correct == true
      image_tag('ok.png', :title => "Бодчихсон")
    elsif correct == false
      image_tag('ng.png', :title => "Бодож чадаагүй")
    else
      ''
    end
  end
end
