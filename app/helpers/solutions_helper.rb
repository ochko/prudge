# -*- coding: utf-8 -*-
module SolutionsHelper
  def highlight(solution)
    options = {encoding: 'utf-8', style: 'monokai'}
    if lexer = Pygments::Lexer.find(solution.language.name)
      options.merge!(lexer: lexer.aliases[0].downcase)
    end
    Pygments.highlight(solution.code, options)
  end

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

  def show_point(point)
    point ? point.round(2) : 0
  end

  def solution_info(solution)
    t('users.solution.info',
      :language => (language = solution.language) ? language.name : t('language.unknown'),
      :date => l(solution.source_updated_at, :format => :date),
      :percent => show_point(solution.percent * 100.0),
      :point => show_point(solution.point))
  end
end
