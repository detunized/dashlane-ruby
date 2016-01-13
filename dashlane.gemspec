# Copyright (C) 2016 Dmitry Yakimenko (detunized@gmail.com).
# Licensed under the terms of the MIT license. See LICENCE for details.

$:.push File.expand_path("../lib", __FILE__)
require "dashlane/version"

Gem::Specification.new do |s|
    s.name        = "dashlane"
    s.version     = Dashlane::VERSION
    s.licenses    = ["MIT"]
    s.authors     = ["Dmitry Yakimenko"]
    s.email       = "detunized@gmail.com"
    s.homepage    = "https://github.com/detunized/dashlane-ruby"
    s.summary     = "Unofficial Dashlane API"
    s.description = "Unofficial Dashlane API"

    s.required_ruby_version = ">= 1.9.3"

    s.add_development_dependency "rake", "~> 10.4.0"
    s.add_development_dependency "rspec", "~> 3.1.0"
    s.add_development_dependency "rspec-its", "~> 1.1.0"
    s.add_development_dependency "coveralls", "~> 0.7.0"

    s.files         = `git ls-files`.split "\n"
    s.test_files    = `git ls-files spec`.split "\n"
    s.require_paths = ["lib"]
end
