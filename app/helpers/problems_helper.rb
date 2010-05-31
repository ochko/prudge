module ProblemsHelper
  def solved_or_not(correct)
    if correct == true
      image_tag('ok.png')
    elsif correct == false
      image_tag('ng.png')
    else
      ''
    end
  end
end
