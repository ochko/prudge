settings = YAML.load_file("#{Rails.root}/config/mail.yml").symbolize_keys

settings.each do |name, setting|
  ActionMailer::Base.send("#{name}=", setting)
end
