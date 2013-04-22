# -*- coding: utf-8 -*-
module SolutionsHelper
  def file_link(solution)
    if solution.user_id == current_user.id
      link_to(solution.source_file_name,
              :controller=>'solutions',
              :action=>'view',
              :id => solution.id)
    else
      solution.source_file_name
    end
  end

  def test_purpose(viewable)
    if viewable
      content_tag(:i, nil, :class => 'muted icon-lock', :title => 'Харагдахгүй тэст')
    else
      link_to(content_tag(:i, nil, :class => 'icon-unlock', :title => 'Ил тест'), result)
    end
  end

  def translate_message(execution_state)
    state = Usage::State.get(execution_state)

    image_tag("run-#{state.abbr}.png",
              :title => t(state.abbr, :scope =>'label.execution'))
  end

  def show_correctness(correct)
    content_tag(:i, nil, :class => correct ? 'icon-check' : 'icon-check-empty')
  end

  def show_percent(percent)
    content_tag(:span, content_tag(:span, "&nbsp;#{percent}%", :style =>"width:#{percent}%; overflow:visible;"), :class=>'percent')
  end
end
