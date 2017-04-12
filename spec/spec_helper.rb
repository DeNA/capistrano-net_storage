require 'capistrano/all'
include Capistrano::DSL

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'capistrano/net_storage/all'
