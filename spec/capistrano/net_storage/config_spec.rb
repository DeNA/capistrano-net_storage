require 'spec_helper'

describe Capistrano::NetStorage::Config do
  let(:config) { Capistrano::NetStorage::Config.new }
  let(:env) { Capistrano::Configuration.env } # Capistrano::NetStorage::Config fetches from global env

  before do
    env.set :application, 'api'
    env.set :deploy_to, '/path/to/deploy'
    env.server 'web1', role: %w(web), active: true
    env.server 'web2', role: %w(web), no_release: true
    env.server 'db1',  role: %w(db), active: true
    env.role :web, %w(web1 web2)
    env.role :db,  %w(db1)
  end

  after do
    Capistrano::Configuration.reset!
  end

  describe 'Configuration params' do
    it 'Default parameters' do
      # executor_class
      expect(config.executor_class(:archiver)).to be Capistrano::NetStorage::Archiver::Zip
      expect(config.executor_class(:scm)).to be Capistrano::NetStorage::SCM::Git
      expect(config.executor_class(:bundler)).to be Capistrano::NetStorage::Bundler
      expect { config.executor_class(:transport) }.to raise_error(ArgumentError, /You have to `set/)
      expect { config.executor_class(:no_such_type) }.to raise_error(ArgumentError, /Invalid type/)

      # Others
      expect(config.servers.map(&:hostname)).to eq %w(web1 db1)
      expect(config.max_parallels).to eq 2
      expect(config.config_files).to be nil
      expect(config.skip_bundle?).to be true
      expect(config.archive_on_missing?).to be true
      expect(config.upload_files_by_rsync?).to be false
      expect(config.rsync_options).to eq({})
      expect(config.multi_app_mode?).to be false
      expect(config.release_app_path.to_s).to eq "/path/to/deploy/current" # SEE: https://github.com/capistrano/capistrano/blob/31e142d56f8d894f28404fb225dcdbe7539bda18/lib/capistrano/dsl/paths.rb#L21-L28
      expect(config.local_base_path.to_s).to eq "#{Dir.pwd}/.local_repo"
      expect(config.local_mirror_path.to_s).to eq "#{config.local_base_path}/mirror"
      expect(config.local_releases_path.to_s).to eq "#{config.local_base_path}/releases"
      expect(config.local_release_path.to_s).to eq "#{config.local_releases_path}/#{config.release_timestamp}"
      expect(config.local_release_app_path.to_s).to eq "#{config.local_releases_path}/#{config.release_timestamp}"
      expect(config.local_bundle_path.to_s).to eq "#{config.local_base_path}/bundle"
      expect(config.local_archives_path.to_s).to eq "#{config.local_base_path}/archives"
      expect(config.local_archive_path.to_s).to eq "#{config.local_archives_path}/#{config.release_timestamp}.zip"
      expect(config.archives_path.to_s).to eq "#{config.deploy_path}/net_storage_archives"
      expect(config.archive_path.to_s).to eq "#{config.archives_path}/#{config.release_timestamp}.zip"
    end

    it 'Customized parameters' do
      archiver_class = Struct.new(:file_extension).new('super.zip')

      {
        net_storage_archiver: archiver_class,
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
        net_storage_multi_app_mode: true,
        net_storage_local_base_path: '/path/to/local_base',
        net_storage_local_mirror_path: '/path/to/local_mirror',
        net_storage_local_releases_path: Pathname.new('/path/to/local_releases'),
        net_storage_local_bundle_path: '/path/to/local_bundle',
        net_storage_local_archives_path: '/path/to/local_archives',
        net_storage_archives_path: '/path/to/archives',
      }.each { |k, v| env.set k, v }

      # executor_class
      expect(config.executor_class(:archiver)).to be archiver_class
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
      expect(config.multi_app_mode?).to be true
      expect(config.release_app_path.to_s).to eq "/path/to/deploy/current/api" # SEE: https://github.com/capistrano/capistrano/blob/31e142d56f8d894f28404fb225dcdbe7539bda18/lib/capistrano/dsl/paths.rb#L21-L28
      expect(config.local_base_path.to_s).to eq '/path/to/local_base'
      expect(config.local_mirror_path.to_s).to eq '/path/to/local_mirror'
      expect(config.local_releases_path.to_s).to eq '/path/to/local_releases'
      expect(config.local_release_path.to_s).to eq "#{config.local_releases_path}/#{config.release_timestamp}"
      expect(config.local_release_app_path.to_s).to eq "#{config.local_releases_path}/#{config.release_timestamp}/api"
      expect(config.local_bundle_path.to_s).to eq '/path/to/local_bundle'
      expect(config.local_archives_path.to_s).to eq '/path/to/local_archives'
      expect(config.local_archive_path.to_s).to eq "#{config.local_archives_path}/#{config.release_timestamp}.super.zip"
      expect(config.archives_path.to_s).to eq '/path/to/archives'
      expect(config.archive_path.to_s).to eq "#{config.archives_path}/#{config.release_timestamp}.super.zip"
    end
  end
end
