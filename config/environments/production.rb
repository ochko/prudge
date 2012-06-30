# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
#ActionMailer::Base.smtp_settings = {
#  :address  => "mail.usi.mn",
#  :port  => 25,
#  :domain  => 'usi.mn'
#}
ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.sendmail_settings = {
  :location       => '/usr/sbin/sendmail',
  :arguments      => '-i -t'
}

memcache_options = {
  :c_threshold => 10_000,
  :compression => false,
  :debug => false,
  :readonly => false,
  :urlencode => false,
  :ttl => 300,
  :namespace => 'coderpro',
  :disabled => false
}

CACHE = MemCache.new memcache_options
CACHE.servers = 'localhost:11211'

