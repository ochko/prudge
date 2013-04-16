YAML.load_file(Rails.root.join('config', 'languages.yml')).each do |options|
  Language.add options
end
