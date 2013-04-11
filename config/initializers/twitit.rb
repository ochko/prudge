cfg = YAML.load_file("#{Rails.root}/config/twitter.yml")

Twitter.configure do |config|
  config.consumer_key = cfg["consumer_key"]
  config.consumer_secret = cfg["consumer_secret"]
  config.oauth_token = cfg["access_token"]
  config.oauth_token_secret = cfg["access_secret"]
end

