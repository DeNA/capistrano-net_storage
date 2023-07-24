# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/net_storage/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-net_storage'
  spec.version       = Capistrano::NetStorage::VERSION
  spec.authors       = ['progrhyme']

  spec.summary       = 'Capistrano SCM Plugin for fast deployment via remote storage'
  spec.description   = <<-EODESC
    A Capistrano SCM Plugin to deploy application via remove storage.
    Logically, this enables O(1) deployment.
  EODESC
  spec.homepage      = 'https://github.com/DeNADev/capistrano-net_storage'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.7'

  spec.add_runtime_dependency 'capistrano', '>= 3.7'
  spec.add_runtime_dependency 'bundler', '>= 2.1'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
end
