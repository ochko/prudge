# Put this in config/application.rb
require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module Prudge
  class Application < Rails::Application
    config.filter_parameters += [:password, :password_confirmation]

    config.autoload_paths += [config.root.join('lib'),
                              config.root.join('app','jobs'),
                              config.root.join('app','abilities'),
                              config.root.join('app','observers'),
                              config.root.join('app','indices')]

    config.encoding = 'utf-8'

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml')]
    config.i18n.available_locales = [:mn, :en, :ru]
    config.i18n.fallbacks = [:en, :mn]

    config.cache_store = :dalli_store, '127.0.0.1', { :namespace => 'prudge' }

    config.session_store :cache_store, :key => '_prudge_session'

    # Make Active Record use UTC-base instead of local time
    config.active_record.default_timezone = :utc

    config.active_record.observers = [:solution_observer,
                                      :problem_observer,
                                      :contest_observer]

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.generators do |g|
      g.test_framework      :rspec, fixture: true
      g.fixture_replacement :fabrication
    end
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      if class_attr_index = html_tag.index('class="')
        html_tag.insert class_attr_index+7, 'error '
      else
        html_tag.insert html_tag.index('>'), ' class="error"'
      end
    }
  end
end
