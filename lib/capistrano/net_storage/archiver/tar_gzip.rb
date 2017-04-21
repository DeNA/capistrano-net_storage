require 'capistrano/net_storage/archiver/base'
require 'capistrano/net_storage/utils'

# Archiver class for .tar.gz format
class Capistrano::NetStorage::Archiver::TarGzip < Capistrano::NetStorage::Archiver::Base
  include Capistrano::NetStorage::Utils

  def check
    run_locally do
      execute :which, 'tar'
    end
  end

  def archive
    c = config
    run_locally do
      within c.local_release_path do
        execute :tar, 'czf', c.local_archive_path, '.'
      end
    end
  end

  def extract
    c = config
    on c.servers, in: :groups, limit: c.max_parallels do
      execute :mkdir, '-p', release_path
      within release_path do
        execute :tar, 'xzf', c.archive_path
        execute :rm, '-f', c.archive_path
      end
    end
  end
end
