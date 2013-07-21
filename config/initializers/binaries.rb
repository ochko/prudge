binaries = YAML.load_file(Rails.root.join 'config', 'binaries.yml')[Rails.env]

Repo.git = binaries['git']
Sandbox::Output.diff = binaries['diff']
