module Capistrano
  module NetStorage
    class ConfigUploader
      # These values are intentionally separated from config and fixed.
      # If you have trouble with these defaults for 10^2 ~ 10^3 servers, please contact us on GitHub.
      # Ideally, you can upload files to 10000 servers in 50 seconds. (2.0 second jitter + 0.5 second execution time)
      MAX_PARALLEL_TO_UPLOAD = 500
      JITTER_DURATION_TO_UPLOAD = 2.0

      # Check for prerequisites.
      # Same interface to delegated class
      def check
      end

      def upload_config_files
        config = Capistrano::NetStorage.config

        on release_roles(:all), in: :groups, limit: MAX_PARALLEL_TO_UPLOAD do |host|
          if config.upload_files_by_rsync?
            rsh_option = Capistrano::NetStorage::ConfigUploader.build_ssh_command(host)
            run_locally do
              sleep Random.rand(JITTER_DURATION_TO_UPLOAD)
              execute :rsync, '-az', "--rsh='#{rsh_option}'", *config.config_files, "#{host.hostname}:#{config.release_app_path.join('config')}"
            end
          else
            # slow and not recommended.
            files.each do |src|
              upload! src, dest_dir
            end
          end
        end
      end

      # Build ssh command with options for rsync
      def self.build_ssh_command(host)
        user_opt    = ''
        key_opt     = ''
        port_opt    = ''
        ssh_options = Capistrano::NetStorage.config.rsync_options

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