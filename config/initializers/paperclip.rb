Paperclip.interpolates :user_id do |solution, style|
  solution.instance.user_id
end

Paperclip.interpolates :problem_id do |solution, style|
  solution.instance.problem_id
end

Paperclip.interpolates :repo_root do |solution, style|
  Repo.root
end

Paperclip.interpolates :test_root do |solution, style|
  Rails.root.join('judge','data')
end
