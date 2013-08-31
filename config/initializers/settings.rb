class Settings
  class << self
    YAML.load_file(Rails.root.join 'config', 'settings.yml')[Rails.env].each do |key, value|
      define_method key do
        value
      end
    end
  end
end
