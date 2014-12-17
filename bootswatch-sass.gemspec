# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bootswatch-sass/version'

Gem::Specification.new do |spec|
  spec.name          = 'bootswatch-sass'
  spec.version       = BootswatchSass::VERSION
  spec.authors       = ['Latchezar Tzvetkoff']
  spec.email         = ['latchezar@tzvetkoff.net']
  spec.summary       = %q{Bootswatch.com themes for Rails}
  spec.homepage      = 'https://github.com/tzvetkoff/bootswatch-sass'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.files        -= ['bump.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'sass', '~> 3.2'
  spec.add_runtime_dependency 'rails', '>= 4.0.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'autoprefixer-rails'
  spec.add_development_dependency 'less', '~> 2.6.0'
  spec.add_development_dependency 'therubyracer'
end
