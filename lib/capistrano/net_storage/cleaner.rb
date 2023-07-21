module Capistrano
  module NetStorage
    # Executor class for cleaning tasks
    class Cleaner
      # Check for prerequisites.
      # Same interface to delegated class
      def check
      end

      # Clean up old release directories on local.
      # Assumes they are under +config.local_releases_path+
      # @see Capistrano::NetStorage::Config#local_releases_path
      def cleanup_local_releases
        config = Capistrano::NetStorage.config

        run_locally do
          clean_targets(config.local_releases_path, /^\d{14}$/)
        end
      end

      # Clean up old archive files on local.
      # Assumes they are under +config.local_archives_path+
      # @see Capistrano::NetStorage::Config#local_archives_path
      def cleanup_local_archives
        config = Capistrano::NetStorage.config

        run_locally do
          clean_targets(config.local_archives_path, /^\d{14}\.[^.]+$/) # Do not care file extension
        end
      end

      # Clean up old archive files on remote servers.
      # Assumes they are under +config.archives_path+
      # @see Capistrano::NetStorage::Config#archives_path
      def cleanup_archives
        config = Capistrano::NetStorage.config

        on release_roles(:all), in: :groups, limit: config.max_parallels do |host|
          clean_targets(config.archives_path, /^\d{14}\.[^.]+$/) # Do not care file extension
        end
      end

      private

      def clean_targets(target_parent_path, target_regexp)
        files_or_directories = capture(:ls, '-x', target_parent_path).split
        targets, invalid = files_or_directories.partition { |e| target_regexp =~ e } # Do not care file extension

        if invalid.any?
          warn "Invalid targets in #{target_parent_path} for #{target_regexp.inspect} on #{host}:\n#{invalid.join("\n")}"
        end

        if targets.count > fetch(:keep_releases)
          info "Keeping #{fetch(:keep_releases)} of #{targets.count} in #{target_parent_path} on #{host}"
          old_targets = (targets - targets.last(fetch(:keep_releases))).map do |target|
            target_parent_path.join(target).to_s
          end
          old_targets.each_slice(100) do |old_targets_batch|
            execute :rm, '-rf', *old_targets_batch
          end
        else
          info "No old targets (keeping newest #{fetch(:keep_releases)}) in #{target_parent_path} on #{host}"
        end
      end
    end
  end
end
