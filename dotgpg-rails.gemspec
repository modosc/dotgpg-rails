# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dotgpg/rails/version'
require "English"

Gem::Specification.new do |spec|
  spec.name          = "dotgpg-rails"
  spec.version       = Dotgpg::Rails::VERSION
  spec.authors       = ["Jonathan Schatz"]
  spec.email         = ["jon@divisionbyzero.com"]
  spec.description   = spec.summary = "Autoload environment variables from dotgpg-encrypted files into Rails."
  spec.homepage      = "https://github.com/vouch/dotgpg-rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "spring"
  spec.add_development_dependency "railties", "~>4.0"

  spec.add_dependency "dotgpg"
  spec.add_dependency "dotgpg-environment", "~> 0.2.1"

end
