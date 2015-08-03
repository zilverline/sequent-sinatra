require_relative 'lib/version'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

Bundler::GemHelper.install_tasks
