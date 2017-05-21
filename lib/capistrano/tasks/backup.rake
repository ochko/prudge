require 'yaml'

namespace :backup do
  desc "Copy production database sql backup to local"
  task :sql do
    on roles(:db) do
      text = capture "cat #{deploy_to}/current/config/database.yml"
      conf = YAML::load(text)['production']

      filename = "#{fetch(:application)}.dump.#{Time.now.to_i}.sql.bz2"
      file = "#{deploy_to}/backup/#{filename}"

      execute "PGPASSWORD=#{conf['password']} pg_dump -w -U #{conf['username']} #{conf['database']} | bzip2 -c > #{file}"

      download! file, "backup/"
    end
  end

  desc "Copy production database binary backup to local"
  task :binary do
    on roles(:db) do
      text = capture "cat #{deploy_to}/current/config/database.yml"
      conf = YAML::load(text)['production']

      filename = "#{fetch(:application)}.#{Time.now.to_i}.dump"
      file = "#{deploy_to}/backup/#{filename}"

      execute "PGPASSWORD=#{conf['password']} pg_dump -U #{conf['username']} -O -x -Fc -f #{file} -v #{conf['database']}"

      download! file, "backup/"
    end
  end
end
