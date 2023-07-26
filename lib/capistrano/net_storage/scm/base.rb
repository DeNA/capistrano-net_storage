module Capistrano
  module NetStorage
    module SCM
      # Abstract class to handle SCM between local_mirror_path and local_release_path
      class Base
        def check
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to check prerequisites for SCM"
        end

        def clone
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to clone repository to `Capistrano::NetStorage.config.local_mirror_path`"
        end

        def update
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to update repository in `Capistrano::NetStorage.config.local_mirror_path`"
        end

        def set_current_revision
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to set current revision by `set :current_revision, revision`"
        end

        def prepare_archive
          raise NotImplementedError, "Implement `#{self.class}#{__method__}` to extract and prepare release into `Capistrano::NetStorage.config.local_release_path`"
        end
      end
    end
  end
end
