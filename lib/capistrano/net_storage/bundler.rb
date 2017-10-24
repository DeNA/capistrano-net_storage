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
        c = config
        run_locally do
          local_release_bundle_path = c.local_release_path.join('vendor', 'bundle')
          execute :mkdir, '-p', local_release_bundle_path
          execute :mkdir, '-p', "#{c.local_release_path}/.bundle"
          # Copy shared gems to release bundle path beforehand to reuse installed previously
          execute :rsync, '-a', "#{c.local_bundle_path}/", "#{local_release_bundle_path}/"

          within c.local_release_path do
            ::Bundler.with_clean_env do
              install_options = %W(
                --gemfile #{c.local_release_path}/Gemfile --deployment --quiet
                --path #{local_release_bundle_path} --without development test
              )
              execute :bundle, 'install', *install_options
              execute :bundle, 'clean'
              # Sync installed gems to shared directory to reuse them next time
              rsync_options = %W(-a --delete #{local_release_bundle_path}/ #{c.local_bundle_path}/)
              execute :rsync, *rsync_options
            end
          end
        end
      end

      # Create +.bundle/config+ at release path on remote servers
      def sync_config
        c = config
        hosts = ::Capistrano::Configuration.env.filter(c.servers)
        on hosts, in: :groups, limit: c.max_parallels do
          within release_path do
            execute :mkdir, '-p', '.bundle'
          end
        end

        bundle_config_path = "#{c.local_base_path}/bundle_config"
        File.open(bundle_config_path, 'w') do |file|
          file.print(<<-EOS)
---
BUNDLE_FROZEN: "1"
BUNDLE_PATH: "#{release_path.join('vendor', 'bundle')}"
BUNDLE_WITHOUT: "development:test"
BUNDLE_DISABLE_SHARED_GEMS: "true"
BUNDLE_BIN: "#{release_path.join('bin')}"
EOS
        end

        upload_files([bundle_config_path], dest_path: release_path.join('.bundle', 'config'))
      end
    end
  end
end
