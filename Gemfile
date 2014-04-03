source 'http://rubygems.org'

gem 'rake', '>= 0.9.2'
gem 'rails', '~>3.2'
gem 'capistrano'
gem 'unicorn'
gem 'pg'
gem 'mysql2', '~> 0.3.12b5' # for thinking-sphinx
gem 'thinking-sphinx', '~>3.0.2'
gem 'bluecloth'
gem 'gravtastic'
gem 'authlogic'
gem 'haml'
gem 'twitter'
gem 'resque'
gem 'json'
gem 'cancan'
gem 'dalli'
gem 'paperclip', '~>3.0'
gem 'kaminari'
gem 'jquery-rails'
gem 'wmd-rails'
gem 'pry'
gem 'foreman'
gem 'coveralls', require: false
gem 'pygments.rb', require: 'pygments'

group :assets do
  gem 'sass-rails',   "~> 3.2"
  gem 'coffee-rails', "~> 3.2"
  gem 'uglifier'
end

group :development do
  gem 'haml-i18n-extractor'
end

group :test do
  gem 'turnip'            # acceptance test
  gem 'rspec'
  gem 'rspec-rails'

  gem 'database_cleaner'  # blank slate for each test run

  gem 'fabrication'       # creates objects for test
  gem 'faker'             # supply fake data for test objects

  gem 'spork'             # preloads rails env for faster test run
  gem 'spork-rails'

  gem 'guard-livereload'  # reloads browser when files change
  gem 'guard-rspec'       # run specs
  gem 'guard-spork'       # loads spork
end
