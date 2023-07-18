require 'capistrano/net_storage/base'
require 'capistrano/net_storage/error'
require 'capistrano/net_storage/config'
require 'capistrano/net_storage/coordinator'
require 'capistrano/net_storage/utils'
require 'capistrano/net_storage/bundler/default'
require 'capistrano/net_storage/bundler/null'
require 'capistrano/net_storage/cleaner'
require 'capistrano/net_storage/archiver/zip'
require 'capistrano/net_storage/archiver/tar_gzip'
require 'capistrano/net_storage/scm/git'
require 'capistrano/net_storage/version'

# See capistrano/net_storage/base.rb
Capistrano::NetStorage.setup! do
  config = Capistrano::NetStorage::Config.new
  {
    config: config,
    coordinator: Capistrano::NetStorage::Coordinator.new(config),
  }
end
