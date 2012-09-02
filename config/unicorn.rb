worker_processes 3
base_dir = "/usr/local/apps/coder/current"
shared_path = "/usr/local/apps/coder/shared"
gem_path = "/usr/local/apps/coder/shared/bundle"
working_directory base_dir

preload_app true

# we destroy all workers who are taking too long
timeout 30

# This is where we specify the socket.
# We will point the upstream Nginx module to this socket later on
listen "/tmp/unicorn-coder.sock", :backlog => 64

pid "#{shared_path}/pids/unicorn.pid"

# Set the path of the log files inside the log folder of the testapp
stderr_path "#{shared_path}/log/unicorn.stderr.log"
stdout_path "#{shared_path}/log/unicorn.stdout.log"

before_exec do |server|
  paths = (ENV["PATH"] || "").split(File::PATH_SEPARATOR)
  paths.unshift "#{gem_path}/ruby/1.8/bin"
  ENV["PATH"] = paths.uniq.join(File::PATH_SEPARATOR)
 
  ENV['GEM_HOME'] = ENV['GEM_PATH'] = gem_path
  ENV['BUNDLE_GEMFILE'] = "#{ENV['PWD']}/Gemfile"
end

before_fork do |server, worker|
# This option works in together with preload_app true setting
# What is does is prevent the master process from holding
# the database connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
# Here we are establishing the connection after forking worker
# processes
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
