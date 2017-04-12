require 'spec_helper'

describe Capistrano::NetStorage::Config do
  let(:config) { Capistrano::NetStorage::Config.new }

  before :context do
    env = Capistrano::Configuration.env
    env.set :deploy_to, '/path/to/deploy'
    env.server 'web1', role: %w(web), active: true
    env.server 'web2', role: %w(web), no_release: true
    env.server 'db1',  role: %w(db), active: true
    env.role :web, %w(web1 web2)
    env.role :db,  %w(db1)
  end

  after :context do
    Capistrano::Configuration.reset!
  end

  describe 'Configuration params' do
    it 'Default parameters' do
      # executor_class
      expect(config.executor_class(:archiver)).to be Capistrano::NetStorage::Archiver::Zip
      expect(config.executor_class(:scm)).to be Capistrano::NetStorage::SCM::Git
      expect(config.executor_class(:bundler)).to be Capistrano::NetStorage::Bundler
      expect { config.executor_class(:transport) }.to raise_error(Capistrano::NetStorage::Error, /You have to set :net_storage_transport/)
      expect { config.executor_class(:no_such_type) }.to raise_error(RuntimeError, /Unknown type!/)

      # Others
      expect(config.servers.map(&:hostname)).to eq %w(web1 db1)
      expect(config.max_parallels).to eq 2
      expect(config.config_files).to be nil
      expect(config.skip_bundle?).to be true
      expect(config.archive_on_missing?).to be true
      expect(config.upload_files_by_rsync?).to be false
      expect(config.rsync_options).to eq({})
      expect(config.local_base_path.to_s).to eq "#{Dir.pwd}/.local_repo"
      expect(config.local_mirror_path.to_s).to eq "#{config.local_base_path}/mirror"
      expect(config.local_releases_path.to_s).to eq "#{config.local_base_path}/releases"
      expect(config.local_release_path.to_s).to eq "#{config.local_releases_path}/#{config.release_timestamp}"
      expect(config.local_bundle_path.to_s).to eq "#{config.local_base_path}/bundle"
      expect(config.local_archive_path.to_s).to eq "#{config.local_release_path}.zip"
      expect(config.archive_path.to_s).to eq "#{config.release_path}.zip"
    end

    it 'Customized parameters' do
      env = Capistrano::Configuration.env
      {
        net_storage_archiver: Object,
        net_storage_scm: Object,
        net_storage_bundler: Object,
        net_storage_transport: Object,
        net_storage_servers: -> { env.roles_for([:web]) },
        net_storage_max_parallels: 5,
        net_storage_config_files: %w(app.yml db.yml).map { |f| "/path/to/config/#{f}" },
        net_storage_with_bundle: true,
        net_storage_archive_on_missing: false,
        net_storage_upload_files_by_rsync: true,
        net_storage_rsync_options: { user: 'bob' },
        net_storage_local_base_path: '/path/to/local_base',
        net_storage_local_mirror_path: '/path/to/local_mirror',
        net_storage_local_releases_path: Pathname.new('/path/to/local_releases'),
        net_storage_local_release_path: '/path/to/local_release',
        net_storage_local_bundle_path: '/path/to/local_bundle',
        net_storage_local_archive_path: '/path/to/local_archive',
        net_storage_archive_path: '/path/to/archive',
      }.each { |k, v| env.set k, v }

      # executor_class
      expect(config.executor_class(:archiver)).to be Object
      expect(config.executor_class(:scm)).to be Object
      expect(config.executor_class(:bundler)).to be Object
      expect(config.executor_class(:transport)).to be Object

      # Others
      expect(config.servers.map(&:hostname)).to eq %w(web1 web2)
      expect(config.max_parallels).to eq 5
      expect(config.config_files).to eq %w(app.yml db.yml).map { |f| "/path/to/config/#{f}" }
      expect(config.skip_bundle?).to be false
      expect(config.archive_on_missing?).to be false
      expect(config.upload_files_by_rsync?).to be true
      expect(config.rsync_options).to eq(user: 'bob')
      expect(config.local_base_path.to_s).to eq '/path/to/local_base'
      expect(config.local_mirror_path.to_s).to eq '/path/to/local_mirror'
      expect(config.local_releases_path.to_s).to eq '/path/to/local_releases'
      expect(config.local_release_path.to_s).to eq '/path/to/local_release'
      expect(config.local_bundle_path.to_s).to eq '/path/to/local_bundle'
      expect(config.local_archive_path.to_s).to eq '/path/to/local_archive'
      expect(config.archive_path.to_s).to eq '/path/to/archive'
    end
  end
end
