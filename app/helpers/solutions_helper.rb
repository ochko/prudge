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

  StateIcons = {
    'ng'     => 'icon-bug',
    'ok'     => 'icon-rocket',
    'timeout'=> 'icon-dashboard',
    'memory' => 'icon-hdd',
    'output' => 'icon-beaker',
    'invalid'=> 'icon-ban-circle',
    'return' => 'icon-warning-sign' }

  def translate_message(execution_state)
    state = Usage::State.get(execution_state)

    content_tag(:i, nil, :class => StateIcons[state.abbr],
                :title => t(state.abbr, :scope =>'label.execution'))
  end

  def show_correctness(correct)
    content_tag(:i, nil, :class => correct ? 'icon-check' : 'icon-check-empty')
  end
end
