require 'pathname'

require 'capistrano/scm/plugin'

require 'capistrano/net_storage/archiver/tar_gzip'
require 'capistrano/net_storage/scm/git'

module Capistrano
  module NetStorage
    class Plugin < ::Capistrano::SCM::Plugin
      # See README.md for details of settings
      def set_defaults
        set_if_empty :net_storage_transport, -> { raise ArgumentError, 'You have to `set(:net_storage_transport, Capistrano::NetStorage::S3)` # or your custom class' }
        set_if_empty :net_storage_archiver, Capistrano::NetStorage::Archiver::TarGzip
        set_if_empty :net_storage_scm, Capistrano::NetStorage::SCM::Git

        set_if_empty :net_storage_config_files, []
        set_if_empty :net_storage_upload_files_by_rsync, true
        set_if_empty :net_storage_rsync_options, -> { fetch(:ssh_options, {}) }

        set_if_empty :net_storage_max_parallels, 1000
        set_if_empty :net_storage_reuse_archive, true

        set_if_empty :net_storage_local_base_path, Pathname.new("#{Dir.pwd}/.local_net_storage")
        set_if_empty :net_storage_archives_path, -> { deploy_path.join('net_storage_archives') }

        set_if_empty :net_storage_skip_bundle, false
        set_if_empty :net_storage_multi_app_mode, false
      end

      def define_tasks
        eval_rakefile File.expand_path("../tasks/net_storage.rake", __dir__)
      end

      def register_hooks
        after  'deploy:new_release_path', 'net_storage:create_release'
        before 'deploy:check', 'net_storage:check'
        after 'deploy:cleanup', 'net_storage:cleanup'
      end
    end
  end
end

# initialization code to access global settings via Capistrano::NetStorage

require 'capistrano/net_storage'
require 'capistrano/net_storage/config'

config = Capistrano::NetStorage::Config.new
Capistrano::NetStorage.setup!(config: Capistrano::NetStorage::Config.new)
