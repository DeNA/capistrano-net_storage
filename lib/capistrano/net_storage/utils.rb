require 'parallel'

require 'capistrano/net_storage/base'

module Capistrano
  module NetStorage
    # Common utility methods
    module Utils
      private

      # @see lib/capistrano/net_storage/base.rb
      def config
        Capistrano::NetStorage.config
      end

      # @param dest_dir [String, Pathname] Destination directory on remote to copy local files into
      # @param dest_path [String, Pathname] Destination file path on remote to copy local files to
      # You can provide either of +dest_dir+ or +dest_path+, or files are copied to same pathes
      def upload_files(files, dest_dir: nil, dest_path: nil)
        c = config
        files.each do |src|
          basename = File.basename(src)
          dest = dest_path || begin
            dir = dest_dir || File.dirname(src)
            File.join(dir, basename)
          end

          if c.upload_files_by_rsync?
            on c.servers, in: :groups, limit: c.max_parallels do |host|
              ssh = build_ssh_command(host)
              run_locally do
                execute :rsync, "-az --rsh='#{ssh}' #{src} #{host}:#{dest}"
              end
            end
          else
            on c.servers, in: :groups, limit: c.max_parallels do
              upload! src, dest
            end
          end
        end
      end

      # Build ssh command with options for rsync
      def build_ssh_command(host)
        user_opt    = ''
        key_opt     = ''
        port_opt    = ''
        ssh_options = config.rsync_options

        if user = host.user || ssh_options[:user]
          user_opt = " -l #{user}"
        end

        if keys = (host.keys.empty? ? ssh_options[:keys] : host.keys)
          keys    = keys.is_a?(Array) ? keys : [keys]
          key_opt = keys.map { |key| " -i #{key}" }.join('')
        end

        if port = host.port || ssh_options[:port]
          port_opt = " -p #{port}"
        end

        "ssh#{user_opt}#{key_opt}#{port_opt}"
      end
    end
  end
end
