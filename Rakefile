require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

if Gem::Version.new(RUBY_VERSION) > Gem::Version.new("2.0")
  namespace :rufo do
    require "rufo"

    def rufo_command(*switches, rake_args)
      files_or_dirs = rake_args[:files_or_dirs] || "."
      args = switches + files_or_dirs.split(" ")
      Rufo::Command.run(args)
    end

    desc "Format Ruby code in current directory"
    task :run, [:files_or_dirs] do |_task, rake_args|
      rufo_command(rake_args)
    end

    desc "Check that no formatting changes are produced"
    task :check, [:files_or_dirs] do |_task, rake_args|
      rufo_command("--check", rake_args)
    end
  end

  task :default => [:spec, :rubocop, :'rufo:check']
else
  # rufo is no longer Ruby 2.0 compatible yet we want to support old Ruby
  task :default => [:spec, :rubocop]
end
