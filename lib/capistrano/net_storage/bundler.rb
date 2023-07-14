require 'bundler'
require 'capistrano/net_storage/utils'

module Capistrano
  module NetStorage
    class Bundler
      include Capistrano::NetStorage::Utils

      def check
        c = config # should be local variable
        run_locally do
          execute :which, 'bundle'
          execute :mkdir, '-p', c.local_bundle_path
        end
      end

      # bundle install locally. `.bundle/config` and installed gems are to be included in the release and archive.
      def install
        c = config # should be local variable
        run_locally do
          within c.local_release_app_path do
            ::Bundler.with_clean_env do
              install_path = Pathname.new('vendor/bundle') # must be a relative path for portability between local and remote
              execute :mkdir, '-p', install_path

              # Sync installed gems from shared directory to speed up installation
              execute :rsync, '-a', '--delete', "#{c.local_bundle_path}/", install_path

              # Always set config
              execute :bundle, 'config', 'set', '--local', 'deployment', 'true'
              execute :bundle, 'config', 'set', '--local', 'path', install_path
              execute :bundle, 'config', 'set', '--local', 'without', 'development test'
              execute :bundle, 'config', 'set', '--local', 'disable_shared_gems', 'true'

              execute :bundle, 'install', '--quiet'
              execute :bundle, 'clean'

              # Sync back to shared directory for the next release
              execute :rsync, '-a', '--delete', "#{install_path}/", c.local_bundle_path
            end
          end
        end
      end
    end
  end
end
