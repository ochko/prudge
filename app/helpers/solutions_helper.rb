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
end
