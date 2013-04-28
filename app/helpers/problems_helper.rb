# -*- coding: utf-8 -*-
module ProblemsHelper
  def solved_or_not(state)
    case state
    when 'passed'
      content_tag(:i, '', :class => 'icon-ok-circle', :title => "Бодчихсон")
    when 'failed'
      content_tag(:i, '', :class => 'icon-remove-circle', :title => "Бодож чадаагүй")
    else
      ''
    end
  end

  def render_viewable(hidden)
    content_tag(:i, '', :class => hidden ? "icon-lock" : "icon-unlock")
  end

  def problem_solution_state(problem)
    solved_or_not problem_solution_states[problem.id]
  end

  def problem_solution_states
    return {} unless current_user
    @problem_solution_states ||= current_user.solutions.
      reduce do |states, solution|
      states[solution.problem_id] = solution.state
      states
    end
  end

  def results_table_horizontal(results)
    matrix_to_table(humanized_results_matrix(results).transpose, "results-table")
  end

  def results_table_vertical(results)
    matrix_to_table(humanized_results_matrix(results), "results-table")
  end

  private

  def humanized_results_matrix(results)
    header = ['Тэст', '', 'Ажиллагаа', 'Хугацаа', 'Санах ой', 'Хариу']
    index = 0
    results.reduce([header]) do |matrix, result|
      matrix << [index += 1,
                 render_viewable(result.hidden), 
                 translate_message(result.execution),
                 sec2milisec(result.time), 
                 result.memory, 
                 link_to(show_correctness(result.correct?), result)]
    end
  end

  def matrix_to_table(matrix, id)
    content = ["<table id='#{id}' class='table table-bordered'>"]
    matrix.each do |row|
      content << "<tr><td>" << row.join('</td><td>') << '</td></tr>'
    end
    content << "</table>"
    content.join
  end

end
