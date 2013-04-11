settings = YAML.load_file("#{Rails.root}/config/mail.yml").symbolize_keys

ActionMailer::Base.smtp_settings = settings
