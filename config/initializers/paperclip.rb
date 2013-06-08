Paperclip.interpolates :user_id do |source, style|
  source.instance.user_id
end

Paperclip.interpolates :problem_id do |source, style|
  source.instance.problem_id
end

Paperclip.interpolates :repo_root do |_, style|
  Repo.root
end

Paperclip.interpolates :test_root do |_, style|
  Rails.root.join('judge','data')
end

Paperclip.interpolates :results_dir do |_, style|
  solution = _.instance.solution
  Repo.root.join(solution.user_id.to_s,
                 solution.problem_id.to_s,
                 "#{solution.id}.results")
end

Paperclip.interpolates :test_id do |_, style|
  _.instance.test_id
end
