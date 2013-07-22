# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'dbt/version'

Gem::Specification.new do |s|
  s.name               = %q{dbt}
  s.version            = Dbt::VERSION
  s.platform           = Gem::Platform::RUBY

  s.authors            = ["Peter Donald"]
  s.email              = %q{peter@realityforge.org}

  s.homepage           = %q{https://github.com/realityforge/dbt}
  s.summary            = %q{A simple tool designed to simplify the creation, migration and deletion of databases.}
  s.description        = %q{A simple tool designed to simplify the creation, migration and deletion of databases.}

  s.rubyforge_project  = %q{dbt}

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {spec}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.default_executable = []
  s.require_paths      = ["lib"]

  s.has_rdoc           = false
  s.rdoc_options       = ["--line-numbers", "--inline-source", "--title", "dbt"]

  s.add_development_dependency(%q<minitest>, ["= 5.0.2"])
  s.add_development_dependency(%q<mocha>, ["= 0.14.0"])
end
