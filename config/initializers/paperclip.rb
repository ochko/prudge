if defined?(Paperclip)
  Paperclip.interpolates :user_id do |solution, style|
    solution.instance.user_id
  end

  Paperclip.interpolates :problem_id do |solution, style|
    solution.instance.problem_id
  end

  Paperclip.interpolates :repository do |solution, style|
    Repo.path
  end
end
