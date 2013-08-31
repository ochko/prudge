Fabricator(:problem) do
  user
  time 1
  memory 64
  name Faker::Company.catch_phrase
  text Faker::Lorem.paragraphs
end

Fabricator(:problem_test) do
  problem
  hidden true
  input { File.new(Rails.root + 'spec/judge/examples/input.txt') }
  output { File.new(Rails.root + 'spec/judge/examples/output.txt') }
end
