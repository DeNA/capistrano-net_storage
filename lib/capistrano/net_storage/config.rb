require 'pathname'

require 'capistrano/net_storage/cleaner'
require 'capistrano/net_storage/bundler/default'
require 'capistrano/net_storage/bundler/null'

module Capistrano
  module NetStorage
    class Config

      # Settings for delegate classes

      def transport_class
        fetch(:net_storage_transport)
      end

      def archiver_class
        fetch(:net_storage_archiver)
      end

      def scm_class
        fetch(:net_storage_scm)
      end

      def cleaner_class
        Capistrano::NetStorage::Cleaner
      end

      def bundler_class
        if skip_bundle?
          Capistrano::NetStorage::Bundler::Null
        else
          Capistrano::NetStorage::Bundler::Default
        end
      end

      # Settings for syncing config

      def config_files
        fetch(:net_storage_config_files)
      end

      def upload_files_by_rsync?
        fetch(:net_storage_upload_files_by_rsync)
      end

      def rsync_options
        fetch(:net_storage_rsync_options)
      end

      # Settings for tuning performance

      def max_parallels
        fetch(:net_storage_max_parallels)
      end

      def reuse_archive?
        fetch(:net_storage_reuse_archive)
      end

      # Settings for behavioral changes

      def skip_bundle?
        fetch(:net_storage_skip_bundle)
      end

      def multi_app_mode?
        fetch(:net_storage_multi_app_mode)
      end

      # Path settings

      # Path to application of remote release_path
      # @return [Pathname]
      def release_app_path
        if multi_app_mode?
          release_path.join(fetch(:application))
        else
          release_path
        end
      end

      # Path to base directory on local
      # @return [Pathname]
      def local_base_path
        Pathname.new(fetch(:net_storage_local_base_path))
      end

      # Path to a mirror repository on local
      # @return [Pathname]
      def local_mirror_path
        local_base_path.join('mirror')
      end

      # Path to keep release directories on local
      # @return [Pathname]
      def local_releases_path
        local_base_path.join('releases')
      end

      # Path to local release directory, where a release is to be prepared
      # @return [Pathname]
      def local_release_path
        local_releases_path.join(release_timestamp)
      end

      # Path to application of local release_path
      # @return [Pathname]
      def local_release_app_path
        if multi_app_mode?
          local_release_path.join(fetch(:application))
        else
          local_release_path
        end
      end

      # Shared cache directory to speed up installing gems on local
      # @return [Pathname]
      def local_bundle_path
        local_base_path.join('bundle')
      end

      # Path of archive directories on local
      # @return [Pathname]
      def local_archives_path
        local_base_path.join('archives')
      end

      # Destination path to archive application on local
      # @return [Pathname]
      def local_archive_path
        local_archives_path.join("#{release_timestamp}.#{archive_file_extension}")
      end

      # Path of archive directories on remote servers
      # @return [Pathname]
      def archives_path
        Pathname.new(fetch(:net_storage_archives_path))
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

      def archive_suffix
        warn <<~WARN
          ######### DEPRECATION WARNING #########

          `Capistrano::NetStorage.config.archive_suffix` is no longer available
          at #{caller[0]}

          Use following method instead.
          `Capistrano::NetStorage.config.archive_file_extension`

        WARN

        archive_file_extension
      end
    end
  end
end
