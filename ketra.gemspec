# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ketra/version'

Gem::Specification.new do |spec|
  spec.name          = "ketra"
  spec.version       = Ketra::VERSION
  spec.authors       = ["Kenneth Priester"]
  spec.email         = ["kennethjpriester@gmail.com"]

  spec.summary       = %q{Provides a friendly ruby-like wrapper for the Ketra API}
  spec.description   = %q{A friendly Ruby interface to the Ketra API}
  spec.homepage      = "http://github.com/kennyjpowers/ketra"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'oauth2', '~> 1.3', '>= 1.3.1'
  spec.add_dependency 'json', '~> 2.1', '~> 2.1.0'
  spec.add_dependency 'addressable', '~> 2.5'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'coveralls', require: false
end
