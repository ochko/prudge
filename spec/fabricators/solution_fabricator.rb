Fabricator(:solution) do
  problem
  user
  language 'c'
  source { File.new(Rails.root + 'spec/judge/examples/hello.c') }
end
