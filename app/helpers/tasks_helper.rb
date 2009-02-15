module TasksHelper
  def status_image(state)
    if state == 'new'
      image_tag('task-new.png')
    elsif state == 'accepting'
      image_tag('task-accepting.png')
    elsif state == 'paying'
      image_tag('task-paying.png')
    elsif state == 'closed'
      image_tag('task-closed.png')
    end
  end
end
