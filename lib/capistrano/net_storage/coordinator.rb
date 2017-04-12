module Capistrano
  module NetStorage
    class Coordinator
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def archiver
        load_executor(:archiver)
      end

      def transport
        load_executor(:transport)
      end

      def cleaner
        load_executor(:cleaner)
      end

      def bundler
        load_executor(:bundler)
      end

      def scm
        load_executor(:scm)
      end

      private

      def load_executor(type)
        @executors ||= {}
        @executors[type] ||= config.executor_class(type).new
      end
    end
  end
end
