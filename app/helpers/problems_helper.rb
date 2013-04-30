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
      reduce({}) do |states, solution|
      states[solution.problem_id] = solution.state
      states
    end
  end

  def submit_path(contest, problem, user)
    if contest && contest.openfor?(user)
      new_contest_problem_solution_path(contest, problem)
    else
      new_problem_solution_path(problem)
    end
  end

end
