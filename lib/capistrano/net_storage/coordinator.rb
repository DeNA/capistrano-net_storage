module Capistrano
  module NetStorage
    class Coordinator
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def archiver
        config.archiver_class.new
      end

      def transport
        config.transport_class.new
      end

      def cleaner
        config.cleaner_class.new
      end

      def bundler
        config.bundler_class.new
      end

      def scm
        config.scm_class.new
      end
    end
  end
end
