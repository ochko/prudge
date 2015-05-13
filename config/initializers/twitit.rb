cfg = YAML.load_file("#{Rails.root}/config/twitter.yml")

ContestTwitBaseJob.configure do |config|
  config.consumer_key        = cfg["consumer_key"]
  config.consumer_secret     = cfg["consumer_secret"]
  config.access_token        = cfg["access_token"]
  config.access_token_secret = cfg["access_token_secret"]
end
