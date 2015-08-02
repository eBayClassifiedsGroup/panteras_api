# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'panteras_api/version'

Gem::Specification.new do |spec|
  spec.name          = "panteras_api"
  spec.version       = PanterasApi::VERSION
  spec.authors       = ["Jonathan Colby"]
  spec.email         = ["jcolby@team.mobile.de"]

  spec.summary       = %q{Checks consistency of services for the Panteras PaaS platform.}
  spec.description   = %q{Verifies services (task) running on consul, mesos, marathon, and docker are consistent.}
  spec.homepage      = "https://github.com/joncolby/panteras_api"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

 # if spec.respond_to?(:metadata)
 #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
 # end

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
