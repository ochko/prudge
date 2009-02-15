module SolutionsHelper
  def file_link(solution)
    if solution.user_id == current_user.id
      link_to(solution.filename,
              :controller=>'solutions',
              :action=>'view',
              :id => solution.id)
    else
      solution.filename
    end
  end
end
