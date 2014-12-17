require 'bootswatch-sass/version'

module BootswatchSass
  class << self
    def load!
      ::Sass.load_paths << stylesheets_path
      ::Sass::Script::Number.precision = [10, ::Sass::Script::Number.precision].max

      require 'bootswatch-sass/engine' if defined?(::Rails)
    end

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
