require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'Open a pry session preloaded with the library'
task :console do
  sh 'pry --gem'
end
task c: :console

RSpec::Core::RakeTask.new(:spec)

task default: :spec
