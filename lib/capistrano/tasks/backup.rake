require 'yaml'

desc "Backup remote production db to local dir"
task :backup do
  on roles(:db) do
    text = capture "cat #{deploy_to}/current/config/database.yml"
    conf = YAML::load(text)['production']

    filename = "#{fetch(:application)}.dump.#{Time.now.to_i}.sql.bz2"
    file = "#{deploy_to}/backup/#{filename}"

    execute "PGPASSWORD=#{conf['password']} pg_dump -w -U #{conf['username']} #{conf['database']} | bzip2 -c > #{file}"
    download! file, "backup/"
  end
end
