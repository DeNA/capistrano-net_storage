require 'capistrano/net_storage/utils'

module Capistrano
  module NetStorage
    # Executor class for cleaning tasks
    class Cleaner
      include Capistrano::NetStorage::Utils

      # Clean up local release directories and archives.
      # Assumes they are under +config.local_releases_path+
      # @see Capistrano::NetStorage::Config#local_releases_path
      def cleanup_local_release
        c = config
        run_locally do
          releases = capture(:ls, '-xtr', c.local_releases_path).split
          # Contains archive files and extracted directories
          if releases.count > fetch(:keep_releases) * 2
            info "Keeping #{fetch(:keep_releases)} * 2 of #{releases.count} local releases"
            olds_str = (releases - releases.last(fetch(:keep_releases) * 2)).map do |file|
              c.local_releases_path.join(file)
            end.join(' ')
            execute :rm, '-rf', olds_str
          else
            info "No old local releases in #{c.local_releases_path}"
          end
        end
      end
    end
  end
end
