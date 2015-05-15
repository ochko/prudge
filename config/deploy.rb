# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'prudge'
set :repo_url, 'git@github.com:ochko/prudge.git'
set :user, 'prudge'

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

set :default_env, { path: "/home/#{fetch :user}/.rbenv/shims:/home/#{fetch :user}/.rbenv/bin:/usr/local/bin:$PATH" }

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

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "BASEDIR=#{fetch(:deploy_to)} #{current_path}/script/unicorn restart"
    end
  end

  desc 'Setup configurations'
  task :setup do
    on roles(:app), in: :sequence, wait: 5 do
      fetch(:linked_files).each do |path|
        filename = path.gsub('config/', '')
        upload! "config/examples/#{filename}", "#{shared_path}/config"
      end
      execute "sed -i 's%APPROOT%#{fetch(:deploy_to)}%g' #{shared_path}/config/monitrc"
      execute "sed -i 's%DEPLOYER%#{fetch(:user)}%g' #{shared_path}/config/monitrc"
      execute "sed -i 's%APPROOT%#{fetch(:deploy_to)}%g' #{shared_path}/config/sphinx.yml"
    end
  end

  desc 'Invoke a rake command on the remote server'
  task :seed => :set_rails_env do
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake 'db:schema:load'
          rake 'db:seed'
        end
      end
    end
  end

  after :publishing, :restart
end
