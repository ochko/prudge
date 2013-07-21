config = YAML.load_file(Rails.root.join 'config', 'resque.yml')[Rails.env]

Resque.redis = config['redis']
Resque.redis.namespace = config['namespace']
