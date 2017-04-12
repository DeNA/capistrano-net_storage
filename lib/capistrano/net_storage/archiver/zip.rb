require 'capistrano/net_storage/archiver/base'
require 'capistrano/net_storage/utils'

# Archiver class for zip format
class Capistrano::NetStorage::Archiver::Zip < Capistrano::NetStorage::Archiver::Base
  include Capistrano::NetStorage::Utils

  def check
    on :local do
      execute :which, 'zip'
    end
  end

  def archive
    c = config
    on :local do
      within c.local_release_path do
        execute :zip, c.local_archive_path, '-r', '.'
      end
    end
  end

  def extract
    c = config
    on c.servers, in: :groups, limit: c.max_parallels do
      execute :unzip, c.archive_path, '-d', release_path
      execute :rm, '-f', c.archive_path
    end
  end
end
