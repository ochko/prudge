require 'yaml'
require 'bundler/capistrano'
# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# Load RVM's capistrano plugin.    
require "rvm/capistrano"

set :rvm_ruby_string, '1.8.7'
set :rvm_type, :user  # Don't use system-wide RVM

set :application, "coder"

set :deploy_to, "/home/ochko/apps/coder"
set :scm, :git 
set :repository, "ochko@code.app.mn:git/coder"
set :branch, "master"
set :deploy_via, :remote_cache

set :user, "ochko"
set :port, 8080
set :ssh_options, { :forward_agent => true }
set :use_sudo, false

role :app, "zulu835.startdedicated.com"
role :web, "zulu835.startdedicated.com"
role :db,  "zulu835.startdedicated.com", :primary => true

after "deploy:update_code", "config:copy", "data:link"
after "deploy:symlink", "config:bundle"

# Overrides for Phusion Passenger
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end


# Configuration Tasks
namespace :config do
  desc "copy shared configurations to current"
  task :copy, :roles => [:app] do
    %w[database.yml twitter.yml].each do |f|
      run "ln -nsf #{shared_path}/config/#{f} #{release_path}/config/#{f}"
    end
  end
  
  desc "bundle gems"
  task :bundle, :roles=> [:app] do
    run "cd #{release_path} && bundle install --path #{shared_path}/../../gems"
  end
end

# Data directory linking
namespace :data do
  desc "link data directories"
  task :link, :roles => [:app] do
    %w[judge].each do |f|
      run "ln -nsf #{shared_path}/#{f} #{release_path}/#{f}"
    end
  end
end

# Sphinx task
namespace :sphinx do
  desc "stop sphinx search engine"
  task :stop, :roles=>[:app] do
    run("cd #{ deploy_to}/current; bundle exec rake thinking_sphinx:stop RAILS_ENV=production")
  end

  desc "rebuild sphinx indexes and start engine"
  task :rebuild, :roles=>[:app] do
    run("cd #{ deploy_to}/current; bundle exec rake thinking_sphinx:rebuild RAILS_ENV=production")
  end
  
  desc "start sphinx search engine"
  task :start, :roles=>[:app] do
    run("cd #{ deploy_to}/current; bundle exec rake thinking_sphinx:start RAILS_ENV=production")
  end
  
  desc "sphinx index"
  task :index, :roles=>[:app] do
    run("cd #{ deploy_to}/current; bundle exec rake thinking_sphinx:index RAILS_ENV=production")
  end
  
  desc "generate sphinx configuration"
  task :configure, :roles=>[:app] do
    run("cd #{ deploy_to}/current; bundle exec rake thinking_sphinx:configure RAILS_ENV=production")
  end
  
  desc "copy existing index database"
  task :copy_data, :roles=>[:app] do
    run "ln -nsf #{ shared_path}/sphinx #{ release_path}/db/sphinx"
  end
  
end

desc "Copy the remote production database to the local dir" 
task :backup, :roles => :db, :only => {  :primary => true } do
  filename = "#{application}.dump.#{Time.now.to_i}.sql.bz2" 
  file = "#{deploy_to}/backup/#{filename}" 
  on_rollback {  delete file }
  text = capture "cat #{deploy_to}/current/config/database.yml"
  db = YAML::load(text)
  run "mysqldump -u #{ db['production']['username']} --password=#{ db['production']['password']} #{ db['production']['database']} | bzip2 -c > #{ file}"  do |ch, stream, out|
    puts out
  end
  `mkdir -p #{ File.dirname(__FILE__)}/../backup/`
  get file, "backup/#{ filename}" 
end
