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
