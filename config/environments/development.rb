# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

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
  :namespace => 'coderdev',
  :disabled => false
}

CACHE = MemCache.new memcache_options
CACHE.servers = 'localhost:11211'
