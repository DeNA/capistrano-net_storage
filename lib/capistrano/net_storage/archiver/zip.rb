require 'capistrano/net_storage/archiver/base'
require 'capistrano/net_storage/utils'

# Archiver class for zip format
class Capistrano::NetStorage::Archiver::Zip < Capistrano::NetStorage::Archiver::Base
  include Capistrano::NetStorage::Utils

  def check
    run_locally do
      execute :which, 'zip'
    end
  end

  def archive
    c = config
    run_locally do
      within c.local_release_path do
        execute :zip, c.local_archive_path, '-r', '.'
      end
    end
  end

  def extract
    c = config
    on c.servers, in: :groups, limit: c.max_parallels do
      execute :mkdir, '-p', c.archives_path
      execute :mkdir, '-p', release_path
      within release_path do
        execute :unzip, c.archive_path
      end
    end
  end
end
