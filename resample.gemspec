# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resample/version'

Gem::Specification.new do |spec|
  spec.name          = 'resample'
  spec.version       = Resample::VERSION
  spec.authors       = ['Sam Rondinelli']
  spec.email         = ['sam.rondinelli3@gmail.com']

  spec.summary       = 'Audio resampling gem'
  spec.description   = 'An audio resampling library based on a reverse-engineering of Resampy'
  spec.homepage      = 'https://www.github.com/SamRond/resample'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
end
