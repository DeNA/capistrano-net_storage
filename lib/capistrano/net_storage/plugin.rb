require 'capistrano/scm/plugin'
require 'capistrano/net_storage'

module Capistrano
  module NetStorage
    class Plugin < ::Capistrano::SCM::Plugin
      def register_hooks
        after  'deploy:new_release_path', 'net_storage:create_release'
        before 'deploy:check', 'net_storage:check'
        before 'deploy:set_current_revision', 'net_storage:set_current_revision'
      end
    end
  end
end
