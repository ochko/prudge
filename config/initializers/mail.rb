settings = YAML.load_file("#{RAILS_ROOT}/config/mail.yml").symbolize_keys

ActionMailer::Base.smtp_settings = settings
