namespace :wmd_on_rails do
  desc "Update the WMD Editor Javascript in your Rails app"
  task :update do
    require File.dirname(__FILE__) + '/../install'
  end
end
