module Capistrano
  module NetStorage
    module Transport
      # Abstract class to transport archive from/to Network Storage
      # @abstract
      class Base
        # Check prerequisites for transport
        # @abstract
        def check
          raise NotImplementedError
        end

        # Find uploaded archive to be deployed and set +:net_storage_uploaded_archive+ its address
        # @abstract
        def find_uploaded
          raise NotImplementedError
        end

        # Upload archive onto remote storage
        # @abstract
        def upload
          raise NotImplementedError
        end

        # Download archive from remote storage to servers.
        # Archive file should be placed at +config.archive_path+
        # @abstract
        def download
          raise NotImplementedError
        end

        # Clean up old archives on remote storage
        # @abstract
        # def cleanup
        #   raise NotImplementedError
        # end
      end
    end
  end
end
