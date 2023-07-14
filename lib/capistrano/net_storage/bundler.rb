require 'bundler'
require 'capistrano/net_storage/utils'

module Capistrano
  module NetStorage
    class Bundler
      include Capistrano::NetStorage::Utils

      def check
        run_locally do
          execute :which, 'bundle'
        end
      end

      # Do bundle install locally. Installed gems are to be included to the release.
      def install
        run_locally do
          local_release_bundle_path = config.local_release_path.join('vendor', 'bundle')
          execute :mkdir, '-p', local_release_bundle_path

          # Copy shared gems to release bundle path beforehand to reuse installed previously
          execute :rsync, '-a', '--delete', "#{config.local_bundle_path}/", local_release_bundle_path

          within config.local_release_path do
            ::Bundler.with_clean_env do
              # Always set config
              execute :bundle, 'config', 'set', '--local', 'deployment', 'true'
              execute :bundle, 'config', 'set', '--local', 'path', Pathname.new('vendor/bundle') # Use relative path to ease rsync
              execute :bundle, 'config', 'set', '--local', 'without', 'development test'
              execute :bundle, 'config', 'set', '--local', 'disable_shared_gems', 'true'

              execute :bundle, 'install', '--quiet'
              execute :bundle, 'clean'

              # Sync installed gems to shared directory to reuse them next time
              execute :rsync, '-a', '--delete', "#{local_release_bundle_path}/", config.local_bundle_path
            end
          end
        end
      end
    end
  end
end
