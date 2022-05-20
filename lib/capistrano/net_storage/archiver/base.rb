module Capistrano
  module NetStorage
    module Archiver
      # Abstract class to archive and extract whole application contents
      # @abstract
      class Base
        # Check prerequisites to archive
        # @abstract
        def check
          raise NotImplementedError
        end

        # Create archive
        # @abstract
        def archive
          raise NotImplementedError
        end

        # Extract archive
        # @abstract
        def extract
          raise NotImplementedError
        end
      end
    end
  end
end
