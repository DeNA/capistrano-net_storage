require 'pathname'

require 'capistrano/net_storage/error'
require 'capistrano/net_storage/bundler'
require 'capistrano/net_storage/archiver/zip'
require 'capistrano/net_storage/scm/git'

module Capistrano
  module NetStorage
    class Config
      def executor_class(type)
        @executor_classes ||= {}
        @executor_classes[type] ||= fetch(:"net_storage_#{type}")
        @executor_classes[type] ||= begin
          case type
          when :archiver
            Capistrano::NetStorage::Archiver::Zip
          when :scm
            Capistrano::NetStorage::SCM::Git
          when :cleaner
            Capistrano::NetStorage::Cleaner
          when :bundler
            Capistrano::NetStorage::Bundler
          when :transport
            msg = 'You have to set :net_storage_transport because no default transport class!'
            raise Capistrano::NetStorage::Error, msg
          else
            raise "Unknown type! #{type}"
          end
        end
      end

      # Servers to deploy
      def servers
        fetch(:net_storage_servers, -> { release_roles(:all) })
      end

      def max_parallels
        @max_parallels ||= fetch(:net_storage_max_parallels, servers.size)
      end

      # Application configuration files to be deployed with
      # @return [Array<String, Pathname>]
      def config_files
        @config_files ||= fetch(:net_storage_config_files)
      end

      # If +true+, skip to bundle gems bundled with target app.
      # Defaults to +true+
      def skip_bundle?
        @has_checked_skip_bundle ||= begin
          @skip_bundle = !fetch(:net_storage_with_bundle)
          true
        end
        @skip_bundle
      end

      # If +true+, create archive ONLY when it's not found on remote storage.
      # Otherwise, create archive ALWAYS.
      # Defaults to +true+
      def archive_on_missing?
        @has_checked_archive_on_missing ||= begin
          @archive_on_missing = fetch(:net_storage_archive_on_missing, true)
          true
        end
        @archive_on_missing
      end

      # If +true+, use +rsync+ to sync config files.
      # Otherwise, use +upload!+ by sshkit.
      # Defaults to +false+
      # @see #rsync_options
      def upload_files_by_rsync?
        @upload_files_by_rsync ||= fetch(:net_storage_upload_files_by_rsync, false)
      end

      # You can set +:user+, +:keys+, +:port+ as ssh options for +rsync+ command to sync configs
      # when +:net_storage_upload_files_by_rsync+ is set +true+.
      # @see #upload_files_by_rsync?
      def rsync_options
        @rsync_options ||= fetch(:net_storage_rsync_options, fetch(:ssh_options, {}))
      end

      #
      # Path settings
      #

      # Path of base directory on local
      # @return [Pathname]
      def local_base_path
        @local_base_path ||= Pathname.new(fetch(:net_storage_local_base_path, "#{Dir.pwd}/.local_repo"))
      end

      # Path to clone repository on local
      # @return [Pathname]
      def local_mirror_path
        @local_mirror_path ||= Pathname.new(fetch(:net_storage_local_mirror_path, local_base_path.join('mirror')))
      end

      # Path to keep release directories on local
      # @return [Pathname]
      def local_releases_path
        @local_releases_path ||= Pathname.new(fetch(:net_storage_local_releases_path, local_base_path.join('releases')))
      end

      # Path to take a snapshot of repository for release on local
      # @return [Pathname]
      def local_release_path
        @local_release_path ||= local_releases_path.join(release_timestamp)
      end

      # Shared directory to install gems on local
      # @return [Pathname]
      def local_bundle_path
        @local_bundle_path ||= Pathname.new(fetch(:net_storage_local_bundle_path, local_base_path.join('bundle')))
      end

      # Path of archive directories on local
      # @return [Pathname]
      def local_archives_path
        @local_archives_path ||= Pathname.new(fetch(:net_storage_local_archives_path, local_base_path.join('archives')))
      end

      # Destination path to archive application on local
      # @return [Pathname]
      def local_archive_path
        @local_archive_path ||= local_archives_path.join("#{release_timestamp}.#{archive_suffix}")
      end

      # Path of archive directories on remote servers
      # @return [Pathname]
      def archives_path
        @archives_path ||= Pathname.new(fetch(:net_storage_archives_path, deploy_path.join('net_storage_archives')))
      end

      # Path of archive file to be downloaded on remote servers
      # @return [Pathname]
      def archive_path
        @archive_path ||= archives_path.join("#{release_timestamp}.#{archive_suffix}")
      end

      # Suffix of archive file
      # @return [String]
      def archive_suffix
        case Capistrano::NetStorage.archiver
        when Capistrano::NetStorage::Archiver::Zip
          'zip'
        when Capistrano::NetStorage::Archiver::TarGzip
          'tar.gz'
        else
          'archive'
        end
      end
    end
  end
end
