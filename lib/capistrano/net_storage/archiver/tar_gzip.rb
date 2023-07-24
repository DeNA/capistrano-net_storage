require 'capistrano/net_storage/archiver/base'

# Archiver class for .tar.gz format
class Capistrano::NetStorage::Archiver::TarGzip < Capistrano::NetStorage::Archiver::Base
  def check
    run_locally do
      execute :which, 'tar'
    end
  end

  def archive
    config = Capistrano::NetStorage.config

    run_locally do
      within config.local_release_path do
        execute :tar, 'czf', config.local_archive_path, '.'
      end
    end
  end

  def extract
    config = Capistrano::NetStorage.config

    on release_roles(:all), in: :groups, limit: config.max_parallels do
      execute :mkdir, '-p', config.archives_path
      execute :mkdir, '-p', release_path
      within release_path do
        execute :tar, 'xzf', config.archive_path
      end
    end
  end

  def self.file_extension
    'tar.gz'
  end
end
