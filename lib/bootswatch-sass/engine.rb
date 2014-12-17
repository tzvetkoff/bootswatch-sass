module BootswatchSass
  class Engine < ::Rails::Engine
    initializer 'bootswatch-sass.assets' do |app|
      %w(fonts javascripts stylesheets).each do |sub|
        app.config.assets.paths << root.join('assets', sub).to_s
      end
      app.config.assets.precompile << %r(bootstrap/glyphicons-halflings-regular\.(?:eot|svg|ttf|woff)$)
    end
  end
end
