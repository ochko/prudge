yml = YAML.load_file Rails.root.join('config', 'config.yml')

config = Prudge::Application.config
config.time_zone = yml['time_zone']
config.i18n.default_locale = yml['default_locale']
