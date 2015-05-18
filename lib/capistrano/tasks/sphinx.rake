namespace :deploy do
  namespace :ts do
    desc 'Generate the Sphinx configuration file'
    task :config => :set_rails_env do
      on primary(:app) do
        within current_path do
          with :rails_env => fetch(:rails_env) do
            rake 'ts:configure'
          end
        end
      end
    end

    desc 'Generate the Sphinx configuration file and process all indices'
    task :index => :set_rails_env do
      on primary(:app) do
        within current_path do
          with :rails_env => fetch(:rails_env) do
            rake 'ts:index'
          end
        end
      end
    end

    desc 'Stop Sphinx, clear files, reconfigure, start Sphinx, generate files'
    task :regenerate => :set_rails_env do
      on primary(:app) do
        within current_path do
          with :rails_env => fetch(:rails_env) do
            rake 'ts:regenerate'
          end
        end
      end
    end
  end
end
