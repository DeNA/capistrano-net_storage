unless defined?(Capistrano::NetStorage::TASK_LOADED) # prevent multiple loads
Capistrano::NetStorage::TASK_LOADED = true

namespace :net_storage do
  # Tasks called by deploy.rake bundled in capistrano core:
  #  - :check
  #  - :create_release
  #  - :set_current_revision
  desc %(Check all components' statuses)
  check_dependencies = %w(archiver transport bundler scm directories).map do |t|
    "net_storage:check:#{t}".to_sym
  end
  task check: check_dependencies

  desc 'Create and deploy archives via remove storage'
  task create_release: :'net_storage:check' do
    config = Capistrano::NetStorage.config
    skip_upload = false
    if config.archive_on_missing?
      invoke 'net_storage:transport:find_uploaded'
      if fetch(:net_storage_uploaded_archive)
        skip_upload = true
      end
    end
    unless skip_upload
      invoke 'net_storage:upload_archive'
    end
    invoke 'net_storage:pull_deploy'
  end

  desc 'Set the revision to be deployed'
  task set_current_revision: :'net_storage:scm:update' do
    Capistrano::NetStorage.scm.set_current_revision
  end

  # Additional tasks for capistrano-net_storage

  desc 'Deploy config files'
  task :sync_config do
    config = Capistrano::NetStorage.config
    Capistrano::NetStorage.scm.sync_config
    Capistrano::NetStorage.bundler.sync_config unless config.skip_bundle?
  end
  after 'net_storage:create_release', 'net_storage:sync_config'

  desc 'Clean up local old archives and snapshots'
  task :cleanup_local_release do
    Capistrano::NetStorage.cleaner.cleanup_local_release
  end
  after 'deploy:cleanup', 'net_storage:cleanup_local_release'

  desc 'Clean up old archives on remote storage'
  task :cleanup_remote_release do
    transport = Capistrano::NetStorage.transport
    next unless transport.respond_to?(:cleanup)
    transport.cleanup
  end
  after 'net_storage:cleanup_local_release', 'net_storage:cleanup_remote_release'

  task prepare_archive: %i(net_storage:scm:update net_storage:check:bundler) do
    config = Capistrano::NetStorage.config
    Capistrano::NetStorage.scm.prepare_archive
    Capistrano::NetStorage.bundler.install unless config.skip_bundle?
  end

  desc 'Create archive to release on local'
  task create_archive: :'net_storage:prepare_archive' do
    Capistrano::NetStorage.archiver.archive
  end

  desc 'Upload archive onto remote storage'
  task upload_archive: :'net_storage:create_archive' do
    Capistrano::NetStorage.transport.upload
  end

  desc 'Deploy via remote storage using uploaded archive'
  task pull_deploy: :'net_storage:transport:find_uploaded' do
    Capistrano::NetStorage.transport.download
    Capistrano::NetStorage.archiver.extract
  end

  namespace :check do
    task :archiver do
      Capistrano::NetStorage.archiver.check
    end

    task :transport do
      Capistrano::NetStorage.transport.check
    end

    task :bundler do
      config = Capistrano::NetStorage.config
      Capistrano::NetStorage.bundler.check unless config.skip_bundle?
    end

    task :scm do
      Capistrano::NetStorage.scm.check
    end

    task :directories do
      config = Capistrano::NetStorage.config
      dirs = [
        config.local_base_path,
        config.local_mirror_path,
        config.local_releases_path,
      ]
      dirs << config.local_bundle_path unless config.skip_bundle?
      run_locally do
        dirs.each { |dir| execute :mkdir, '-p', dir }
      end
    end
  end

  namespace :scm do
    task clone: %i(net_storage:check:scm net_storage:check:directories) do
      Capistrano::NetStorage.scm.clone
    end

    task update: :'net_storage:scm:clone' do
      Capistrano::NetStorage.scm.update
    end

    task set_current_revision: :'net_storage:scm:update' do
      Capistrano::NetStorage.scm.set_current_revision
    end
  end

  namespace :transport do
    task find_uploaded: :'net_storage:scm:set_current_revision' do
      Capistrano::NetStorage.transport.find_uploaded
    end
  end
end

end
