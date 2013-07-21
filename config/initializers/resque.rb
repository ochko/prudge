config = YAML::load(File.open(Rails.root.join('config', 'resque.yml')))[Rails.env]

Resque.redis = config['redis']
Resque.redis.namespace = config['namespace']
