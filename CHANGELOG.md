## 1.0.0 (2023/08/07)

**Scalable by Default**

Major Update by @aeroastro

The main objective of this update is scalable by default. You can enjoy the scalability and fine-tuned settings just out of the box.

New Features:

- `:net_storage_multi_app_mode` (default: `false`) has been introduced to deploy a repository with multiple applications (#14)
  - This mode is more convenient than `repo_tree` when there is a dependency among subdirectories.
- Plugin style is now officially supported for Capistrano >= 3.7 (#22)
- Officially supported task hook point is introduced `after 'net_storage:prepare_archive'` (#22)
- `:net_storage_keep_remote_archives` has been introduced to control the number of remote archives (#24)

Changes

- Default archiver is now `.tar.gz` instead of `.zip` to improve integrity (#19)
- Default value of `:net_storage_config_files` has been changed from `nil` to `[]` (#20)
- Minimum required Ruby version is now 2.7 (#21)
- Minimum required Bundler version is now 2.1 (#21)
- Minimum required Capistrano version is now 3.7.0 (#22)
- `:net_storage_archive_on_missing` has been renamed to `:net_storage_reuse_archive` (#22)
- Default value of `:net_storage_max_parallels` is now 1000 (#22)
- Default value of `:net_storage_local_base_path` is now `.local_net_storage` (#22)
- `:net_storage_local_#{mirror,releases,bundle,archives}_path` has been removed from settings (#22)
- `:net_storage_with_bundle` is renamed to `:net_storage_skip_bundle` (#22)
- Default value of `:net_storage_skip_bundle` is changed to conduct `bundle install` (#22)
- Default value of `:net_storage_upload_files_by_rsync` is now `true` (#22)


Bug Fixes:

- `IOError: closed stream` error from SSHKit has been fixed. (#13)
- Deprecation warning of `bundle install --path` and other option have been fixed (#14)
- Fix bug when `config_files` is an empty array (#14)
- Fix deprecation warning coming from Bundler.with_clean_env (#21)
- Allow Capistrano::NetStorage to deploy different Ruby versions (#28)

Improvement:

- The speed of config file deployment is dramatically improved by reducing `rsync` to 1 command (#13)
- The need of `.bundle/config` deployment is properly removed, and deployment becomes faster. (#14)
- Jitter duration has been introduced to increase stability for `rsync` and transport layer. (#22)

Internal Improvement (mainly for maintainers and plugin developers):

- Delegation system has been improved.
  - `file_extension` is delegated to `:archiver` class (#14)
  - Checking `local_bundle_path` is delegated to `:bundler` class (#14)
- `rsync` mechanism between cache and install directory has been improved (#14)
- Caching at `Capistrano::NetStorage::Config` has been removed to remove potential bugs (#14)
- `Capistrano::NetStorage::Transport#cleanup` is now mandatory (#15)
- GitHub Actions have been introduced for CI (#16, #17, #18)
- `:net_storage_archiver` class must implement `Capistrano::NetStorage::Archiver::SomeClass#.file_extension` (#22)
- `Capistrano::NetStorage::Config#archive_suffix` now shows deprecation warnings. (#22)
- All the default settings can be consulted via `Capistrano::NetStorage::Plugin#set_defaults` (#22)
- `:net_storage_servers` has been removed (#22)
- Large-scale refactoring (#22)
- `NotImplementedError` message has been improved to ease debugging for plugin developers (#25)


## 0.4.0 (2022/05/17)

Fix Bug:

- Fix a cleanup issue reported at #9 (#12) @naro143
  - Before:
    - Archives such as `.tar.gz` and `.zip` are handled in `releases` directory of each server.
    - Incomplete deployment leads to uncollected garbage directory under `releases`.
  - After:
    - Archives are handled within `#{deploy_to}/net_storage_archives` directory of each server.
    - NetStorage cleanup `net_storage_archives` directory just as Capistrano do in `releases` directory.
    - One successful deployment can cleanup old archives and there is no more Capistrano warnings.
  - This includes the same cleanup policy for `local_releases_path` and `local_archives_path` of NetStorage.

Changes:

- Change task name `net_storage:cleanup_remote_release` to `net_storage:cleanup_archives_on_remote_storage`

## 0.3.2 (2017/11/7)

Fix Bug:

- Use Capistrano::Configuration.env.filter (#8) @SpringMT

## 0.3.1 (2017/11/6)

Fix Bug:

- Enable HOSTS settings when using cap deploy --hosts (#6) @SpringMT

## 0.3.0 (2017/7/14)

Improve:

- Support capistrano's SCM plugin system (#4) @progrhyme

## 0.2.3 (2017/5/10)

Minor Modify:

- Use `git rev-list` instead of `git rev-parse` to handle annotated tag better
(#3) @aeroastro

## 0.2.2 (2017/5/9)

Feature:

- Add a framework task `net_storage:cleanup_remote_release` to clean up old
archives on remote storage (#2) @progrhyme

## 0.2.1 (2017/4/21)

Internal Change:

- Use `run_locally` instead of `on :local` (#1) @progrhyme

## 0.2.0 (2017/4/12)

Initial release.
