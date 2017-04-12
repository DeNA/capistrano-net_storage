require 'forwardable'

module Capistrano
  module NetStorage
    class << self
      attr_reader :config, :coordinator

      extend Forwardable
      def_delegators :coordinator, :archiver, :scm, :cleaner, :bundler, :transport
    end

    def self.setup!(params = nil)
      params       ||= yield
      @config        = params[:config]
      @coordinator   = params[:coordinator]
    end
  end
end
