# SEE: https://github.com/capistrano/capistrano/blob/31e142d56f8d894f28404fb225dcdbe7539bda18/lib/capistrano/scm/tasks/git.rake
namespace :net_storage do
  desc 'Check '
  task :check do
    Capistrano::NetStorage.transport.check
    Capistrano::NetStorage.archiver.check
    Capistrano::NetStorage.scm.check
    Capistrano::NetStorage.bundler.check
    Capistrano::NetStorage.cleaner.check

    config = Capistrano::NetStorage.config
    run_locally do
      execute(:mkdir, '-p',
        config.local_base_path,
        config.local_mirror_path,
        config.local_releases_path,
        config.local_archives_path,
      )
    end
  end

  task :prepare_mirror_repository do
    Capistrano::NetStorage.scm.clone
    Capistrano::NetStorage.scm.update
    Capistrano::NetStorage.scm.set_current_revision # :current_revision is set here, not in net_storage:set_current_revision
  end

  desc 'Create and deploy archives via remove storage'
  task create_release: :'net_storage:prepare_mirror_repository' do
    config = Capistrano::NetStorage.config

    if !config.reuse_archive? || !Capistrano::NetStorage.transport.archive_exists?
      invoke 'net_storage:prepare_archive'
      Capistrano::NetStorage.archiver.archive
      Capistrano::NetStorage.transport.upload
    end

    Capistrano::NetStorage.transport.download
    Capistrano::NetStorage.archiver.extract

    Capistrano::NetStorage.scm.sync_config
  end

  desc 'Clean up old release directories on local'
  task :cleanup do
    Capistrano::NetStorage.cleaner.cleanup_local_releases
    Capistrano::NetStorage.cleaner.cleanup_local_archives
    Capistrano::NetStorage.cleaner.cleanup_archives
    Capistrano::NetStorage.transport.cleanup
  end

  desc 'Prepare archive (You can hook your own preparation after this)'
  task :prepare_archive do
    Capistrano::NetStorage.scm.prepare_archive
    Capistrano::NetStorage.bundler.install
  end
end
