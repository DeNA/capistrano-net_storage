module Capistrano
  module NetStorage
    class Coordinator
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def archiver
        config.executor_class(:archiver).new
      end

      def transport
        config.executor_class(:transport).new
      end

      def cleaner
        config.executor_class(:cleaner).new
      end

      def bundler
        config.executor_class(:bundler).new
      end

      def scm
        config.executor_class(:scm).new
      end
    end
  end
end
