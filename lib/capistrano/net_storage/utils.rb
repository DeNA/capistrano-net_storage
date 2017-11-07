require 'parallel'

require 'capistrano/net_storage/base'

module Capistrano
  module NetStorage
    # Common utility methods
    module Utils
      # @see lib/capistrano/net_storage/base.rb
      def config
        Capistrano::NetStorage.config
      end

      # @param dest_dir [String, Pathname] Destination directory on remote to copy local files into
      def upload_files(files, dest_dir)
        c = config
        #hosts = ::Capistrano::Configuration.env.filter(c.servers)
        if c.upload_files_by_rsync?
          on c.servers, in: :groups, limit: c.max_parallels do |host|
          #Parallel.each(hosts, in_threads: c.max_parallels) do |host|
            Capistrano::NetStorage::Utils.build_ssh_command('host')
            run_locally do
              files.each do |src|
                execute :rsync, "-az --rsh='#{ssh}' #{src} #{host}:#{dest_dir}"
              end
            end
          end
        else
          on c.servers, in: :groups, limit: c.max_parallels do
            files.each do |src|
              upload! src, dest_dir
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
