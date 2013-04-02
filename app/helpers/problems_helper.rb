# -*- coding: utf-8 -*-
module ProblemsHelper
  def solved_or_not(state)
    case state
    when 'passed'
      image_tag('ok.png', :title => "Бодчихсон")
    when 'failed'
      image_tag('ng.png', :title => "Бодож чадаагүй")
    else
      ''
    end
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
end
