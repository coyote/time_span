# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "time_span/version"

Gem::Specification.new do |s|
  s.name        = "time_span"
  s.version     = TimeSpan::VERSION
  s.authors     = ["Craig A. Cook"]
  s.email       = ["craig.a.cook@gmail.com"]
  s.homepage    = "https://github.com/coyote/time_span"
  s.summary     = %q{Time Span}
  s.description = %q{Time spans, including many comparators. Abstract time ONLY.}
  s.license     = 'MIT'

  s.rubyforge_project = "time_span"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # dependencies

  s.add_development_dependency "rspec"
  s.add_development_dependency  "rubygems-test"

end
