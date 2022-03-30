lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "journald/modules/version"

Gem::Specification.new do |spec|
  spec.name = "journald-logger"
  spec.version = Journald::Logger::VERSION
  spec.authors = ["Anton Smirnov"]
  spec.email = ["sandfox@sandfox.me"]
  spec.summary = %q{systemd-journal native logger}
  spec.homepage = "https://github.com/theforeman/journald-logger"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_runtime_dependency "journald-native", "~> 1.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rufo"
  spec.add_development_dependency "simplecov"

  spec.metadata['rubygems_mfa_required'] = 'true'
end
