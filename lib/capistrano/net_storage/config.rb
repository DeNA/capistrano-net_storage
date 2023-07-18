require 'pathname'

require 'capistrano/net_storage/archiver/tar_gzip'
require 'capistrano/net_storage/scm/git'
require 'capistrano/net_storage/cleaner'
require 'capistrano/net_storage/bundler/default'
require 'capistrano/net_storage/bundler/null'

module Capistrano
  module NetStorage
    class Config
      DEFAULT_LOCAL_BASE_PATH = Pathname.new("#{Dir.pwd}/.local_repo")

      def archiver_class
        fetch(:net_storage_archiver, Capistrano::NetStorage::Archiver::TarGzip)
      end

      def scm_class
        fetch(:net_storage_scm, Capistrano::NetStorage::SCM::Git)
      end

      def cleaner_class
        fetch(:net_storage_cleaner, Capistrano::NetStorage::Cleaner)
      end

      def bundler_class
        return Capistrano::NetStorage::Bundler::Null if fetch(:net_storage_skip_bundle)

        fetch(:net_storage_bundler, Capistrano::NetStorage::Bundler::Default)
      end

      def transport_class
        fetch(:net_storage_transport) or raise ArgumentError, 'You have to `set(:net_storage_transport, CustomClass)`'
      end

      # Servers to deploy
      def servers
        fetch(:net_storage_servers, -> { release_roles(:all) })
      end

      def max_parallels
        fetch(:net_storage_max_parallels, servers.size)
      end

      # Application configuration files to be deployed with
      # @return [Array<String, Pathname>]
      def config_files
        fetch(:net_storage_config_files, [])
      end

      # If +true+, skip to bundle gems bundled with target app.
      # Defaults to +true+
      def skip_bundle?
        !fetch(:net_storage_with_bundle, false) # just for backward compatibility
      end

      # If +true+, create archive ONLY when it's not found on remote storage.
      # Otherwise, create archive ALWAYS.
      # Defaults to +true+
      def archive_on_missing?
        fetch(:net_storage_archive_on_missing, true)
      end

      # If +true+, use +rsync+ to sync config files.
      # Otherwise, use +upload!+ by sshkit.
      # Defaults to +false+
      # @see #rsync_options
      def upload_files_by_rsync?
        fetch(:net_storage_upload_files_by_rsync, false)
      end

      # You can set +:user+, +:keys+, +:port+ as ssh options for +rsync+ command to sync configs
      # when +:net_storage_upload_files_by_rsync+ is set +true+.
      # @see #upload_files_by_rsync?
      def rsync_options
        fetch(:net_storage_rsync_options, fetch(:ssh_options, {}))
      end

      # If your repository consists of multiple Rails apps, you can enable this for seamless deployment
      def multi_app_mode?
        fetch(:net_storage_multi_app_mode, false)
      end

      #
      # Path settings
      #

      # Path to application of remote release_path
      def release_app_path
        multi_app_mode? ? Pathname.new(release_path).join(fetch(:application)) : Pathname.new(release_path)
      end

      # Path of base directory on local
      # @return [Pathname]
      def local_base_path
        Pathname.new(fetch(:net_storage_local_base_path, DEFAULT_LOCAL_BASE_PATH))
      end

      # Path to clone repository on local
      # @return [Pathname]
      def local_mirror_path
        Pathname.new(fetch(:net_storage_local_mirror_path, local_base_path.join('mirror')))
      end

      # Path to keep release directories on local
      # @return [Pathname]
      def local_releases_path
        Pathname.new(fetch(:net_storage_local_releases_path, local_base_path.join('releases')))
      end

      # Path to take a snapshot of repository for release on local
      # @return [Pathname]
      def local_release_path
        local_releases_path.join(release_timestamp)
      end

      # Path to application of local release_path
      def local_release_app_path
        multi_app_mode? ? local_release_path.join(fetch(:application)) : local_release_path
      end

      # Shared directory to install gems on local
      # @return [Pathname]
      def local_bundle_path
        Pathname.new(fetch(:net_storage_local_bundle_path, local_base_path.join('bundle')))
      end

      # Path of archive directories on local
      # @return [Pathname]
      def local_archives_path
        Pathname.new(fetch(:net_storage_local_archives_path, local_base_path.join('archives')))
      end

      # Destination path to archive application on local
      # @return [Pathname]
      def local_archive_path
        local_archives_path.join("#{release_timestamp}.#{archive_file_extension}")
      end

      # Path of archive directories on remote servers
      # @return [Pathname]
      def archives_path
        Pathname.new(fetch(:net_storage_archives_path, deploy_path.join('net_storage_archives')))
      end

      # Path of archive file to be downloaded on remote servers
      # @return [Pathname]
      def archive_path
        archives_path.join("#{release_timestamp}.#{archive_file_extension}")
      end

      # Suffix of archive file
      # @return [String]
      def archive_file_extension
        archiver_class.file_extension
      end

      alias archive_suffix archive_file_extension # backward compatibility
    end
  end
end
