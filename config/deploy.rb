# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'coder'
set :repo_url, 'git@github.com:ochko/prudge.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files,
    fetch(:linked_files, []).push(
      'config/binaries.yml',
      'config/config.yml',
      'config/database.yml',
      'config/languages.yml',
      'config/mail.yml',
      'config/resque.yml',
      'config/settings.yml',
      'config/sphinx.yml',
      'config/twitter.yml',
      'config/monitrc',
      'config/unicorn.rb'
    )

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push(
      'judge/data',
      'judge/sandbox',
      'judge/solutions',
      'log',
      'tmp/pids',
      'tmp/cache',
      'tmp/sockets',
    )

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# capistrano-rbenv
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

# capistrano-rails
set :conditionally_migrate, true

# capistrano-bundler
set :bundle_jobs, 2

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end