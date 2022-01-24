# frozen_string_literal: true

require "bundler/gem_tasks"

begin
  require "rubocop/rake_task"
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  RuboCop::RakeTask.new
rescue LoadError => e
  puts e
end

task default: [:rubocop, :spec]
