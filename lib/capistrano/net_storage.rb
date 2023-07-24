module Capistrano
  module NetStorage
    class << self
      attr_reader :config

      def setup!(config:)
        @config = config
      end

      def transport
        config.transport_class.new
      end

      def archiver
        config.archiver_class.new
      end

      def scm
        config.scm_class.new
      end

      def cleaner
        config.cleaner_class.new
      end

      def bundler
        config.bundler_class.new
      end

      def config_uploader
        config.config_uploader_class.new
      end
    end
  end
end
