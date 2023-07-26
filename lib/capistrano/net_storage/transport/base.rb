module Capistrano
  module NetStorage
    module Transport
      # Abstract class to upload archive from local to storage and download from storage to remote
      class Base
        def check
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to check prerequisites for Transport"
        end

        def archive_exists?
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to test archive on storage corresponding to `fetch(:current_revision) + Config#archive_file_extension`"
        end

        def upload
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to upload archive from `Capistrano::NetStorage.config.local_archive_path` to remote storage"
        end

        def download
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to download archive from remote storage to `Capistrano::NetStorage.config.archive_path`"
        end

        def cleanup
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to clean archives on remote storage to `Capistrano::NetStorage.config.keep_remote_archives`"
        end
      end
    end
  end
end
