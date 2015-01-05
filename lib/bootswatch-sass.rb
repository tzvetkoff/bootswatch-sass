require 'bootswatch-sass/version'

module BootswatchSass
  class << self
    # Inspired by bootstrap-sass & kaminari

    def load!
      configure_sass!
      register_rails_engine! if rails?
    end

    def configure_sass!
      ::Sass.load_paths << stylesheets_path
      ::Sass::Script::Number.precision = [10, ::Sass::Script::Number.precision].max
    end

    def register_rails_engine!
      require 'bootswatch-sass/engine' if rails?
    end

    # Environment

    def rails?
      defined?(::Rails)
    end

    # Paths

    def gem_path
      @gem_path ||= File.expand_path('..', File.dirname(__FILE__))
    end

    def assets_path
      @assets_path ||= File.join(gem_path, 'assets')
    end

    def fonts_path
      File.join(assets_path, 'fonts')
    end

    def javascripts_path
      File.join(assets_path, 'javascripts')
    end

    def stylesheets_path
      File.join(assets_path, 'stylesheets')
    end
  end
end

BootswatchSass.load!
