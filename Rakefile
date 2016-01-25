# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :default => :spec

# Spec
RSpec::Core::RakeTask.new :spec do |task|
    task.rspec_opts = "--format documentation --color"
end

# Example
task :example do
    ruby "-Ilib", "example/example.rb"
end
