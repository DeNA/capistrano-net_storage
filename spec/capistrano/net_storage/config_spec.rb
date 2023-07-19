require 'spec_helper'

module MyTest
  class Transport; end
  class SCM; end
end

describe Capistrano::NetStorage::Config do
  let(:config) { Capistrano::NetStorage::Config.new }
  let(:env) { Capistrano::Configuration.env } # Capistrano::NetStorage::Config fetches from global env

  before do
    Capistrano::Configuration.reset!

    env.instance_eval(&capfile)
    invoke! 'load:defaults'
  end

  describe 'Configuration params' do
    context 'with minimum settings' do
      let(:capfile) do
        -> (_env) {
          set :application, 'api'
          set :deploy_to, '/path/to/deploy'
          role :web, %w(web1 web2)
          role :db,  %w(db1)

          set :net_storage_transport, MyTest::Transport
        }
      end

      it 'yields default parameter defined in Capistrano::NetStorage::Plugin#set_defaults' do
        expect(config).to have_attributes(
          transport_class: MyTest::Transport,
          archiver_class: Capistrano::NetStorage::Archiver::TarGzip,
          scm_class: Capistrano::NetStorage::SCM::Git,

          config_files: [],
          upload_files_by_rsync?: true,
          rsync_options: {},

          max_parallels: 3,
          reuse_archive?: true,

          local_base_path: Pathname.new("#{Dir.pwd}/.local_repo"),
          archives_path: Pathname.new('/path/to/deploy/net_storage_archives'),

          skip_bundle?: false,
          multi_app_mode?: false,
        )

      end

      it 'yields directory structures under local_base_path' do
        base_path = config.local_base_path
        timestamp = config.release_timestamp

        expect(config).to have_attributes(
          local_mirror_path: base_path.join('mirror'),
          local_bundle_path: base_path.join('bundle'),
          local_releases_path: base_path.join('releases'),
          local_release_path: base_path.join('releases', timestamp),
          local_release_app_path: base_path.join('releases', timestamp),
          local_archives_path: base_path.join('archives'),
          local_archive_path: base_path.join('archives', "#{config.release_timestamp}.tar.gz"),
        )
      end

      it 'yields directory structures under archives_path' do
        archives_path = config.archives_path

        expect(config.archive_path).to eq archives_path.join("#{config.release_timestamp}.tar.gz")
      end

      it 'yields release_app_path identical to release_path for multi_app_mode: false' do
        path = Pathname.new('/path/to/deploy/current') # SEE: https://github.com/capistrano/capistrano/blob/31e142d56f8d894f28404fb225dcdbe7539bda18/lib/capistrano/dsl/paths.rb#L21-L28

        expect(config.release_path).to eq path
        expect(config.release_app_path).to eq path
      end
    end

    context 'with custom config' do
      let(:capfile) do
        -> (_env) {
          set :application, 'api'
          set :deploy_to, '/path/to/deploy'
          role :web, %w(web1 web2)
          role :db,  %w(db1)

          set :net_storage_transport, MyTest::Transport

          set :net_storage_archiver, Capistrano::NetStorage::Archiver::Zip
          set :net_storage_scm, MyTest::SCM

          set :net_storage_config_files, ['foo', 'bar']
          set :net_storage_upload_files_by_rsync, false
          set :net_storage_rsync_options, { user: 'bob' }

          set :net_storage_max_parallels, 100
          set :net_storage_reuse_archive, false

          set :net_storage_local_base_path, 'hoge'

          set :net_storage_skip_bundle, true
          set :net_storage_multi_app_mode, true
        }
      end

      it 'overwrites default parameters' do
        expect(config).to have_attributes(
          archiver_class: Capistrano::NetStorage::Archiver::Zip,
          scm_class: MyTest::SCM,

          config_files: ['foo', 'bar'],
          rsync_options: { user: 'bob' },

          max_parallels: 100,
          reuse_archive?: false,

          local_base_path: Pathname.new('hoge'),

          skip_bundle?: true,
          multi_app_mode?: true,
        )
      end

      it 'sets Bundler::Null for skip_bundle: false' do
        expect(config.bundler_class).to be Capistrano::NetStorage::Bundler::Null
      end

      it 'sets app_path for multi_app_mode: true' do
        expect(config.release_app_path).to eq Pathname.new('/path/to/deploy/current/api')
        expect(config.local_release_app_path).to eq config.local_release_path.join('api')
      end

      it 'sets valid file extension for archiver_class' do
        expect(config.local_archive_path.basename).to eq Pathname.new("#{config.release_timestamp}.zip")
        expect(config.archive_path.basename).to eq Pathname.new("#{config.release_timestamp}.zip")
      end
    end
  end
end
