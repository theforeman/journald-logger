require 'bundler/gem_tasks'
require 'rake/extensiontask'

spec = Gem::Specification.load('journald-logger.gemspec')
Rake::ExtensionTask.new('journald_logger', spec)

task :build => :compile do
  # just add prerequisite
end
