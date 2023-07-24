$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

# Load files to simulate installing Capistrano plugins

# https://github.com/capistrano/capistrano/blob/31e142d56f8d894f28404fb225dcdbe7539bda18/bin/cap
require "capistrano/all"

# https://github.com/capistrano/capistrano/blob/31e142d56f8d894f28404fb225dcdbe7539bda18/lib/capistrano/templates/Capfile
require "capistrano/setup"
require "capistrano/deploy"

require 'capistrano/net_storage/plugin'
install_plugin Capistrano::NetStorage::Plugin
