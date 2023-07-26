module Capistrano
  module NetStorage
    module Archiver
      # Abstract class to archive release in local and extract release in remote
      class Base
        def check
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to check prerequisites for Archiver"
        end

        def archive
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to create archive from `Capistrano::NetStorage.config.local_release_path` to `Capistrano::NetStorage.config.local_archive_path`"
        end

        def extract
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to extract archive from `Capistrano::NetStorage.config.archive_path` to `release_path`"
        end

        def self.file_extension
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to return file extension String such as 'zip' or 'tar.gz'"
        end
      end
    end
  end
end
