require_relative "lib/journald/modules/version"

Gem::Specification.new do |spec|
  spec.name = "journald-logger"
  spec.version = Journald::Logger::VERSION
  spec.authors = ["Anton Smirnov"]
  spec.email = ["sandfox@sandfox.me"]
  spec.summary = %q{systemd-journal native logger}
  spec.homepage = "https://github.com/theforeman/journald-logger"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0", "< 3.4"

  spec.add_dependency "journald-native", "~> 1.0"

  spec.metadata["rubygems_mfa_required"] = "true"
end
