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
