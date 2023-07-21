module Capistrano
  module NetStorage
    module SCM
      # Base internal SCM class of Capistrano::Netstrage
      # @abstract
      class Base
        # Check SCM prerequisites
        # @abstract
        def check
          raise NotImplementedError
        end

        # Clone repository to local
        # @abstract
        def clone
          raise NotImplementedError
        end

        # Update local repository
        # @abstract
        def update
          raise NotImplementedError
        end

        # Set current revision to be deployed of the repository
        # @abstract
        def set_current_revision
          raise NotImplementedError
        end

        # Prepare snapshot of repository to be archived for release
        # @abstract
        def prepare_archive
          raise NotImplementedError
        end

        # Copy local config files to servers
        def sync_config
          return if config.config_files.empty?

          upload_files(config.config_files, config.release_app_path.join('config'))
        end
      end
    end
  end
end
