# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'active_osm/version'

# test
Gem::Specification.new do |s|
  s.name        = "activeosm"
  s.version     = ActiveOSM::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alban Peignier", "Marc Florisson", "Luc Donnet"]
  s.email       = ["alban@tryphon.eu", "mflorisson@cityway.fr", "luc.donnet@free.fr" ]
  s.homepage    = "http://github.com/dryade/activeosm"
  s.summary     = %q{Manage OSM data import}
  s.description = %q{Manage OSM data import}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rails', '>= 3.2.8'
  s.add_runtime_dependency 'geokit'

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "pg"
end
