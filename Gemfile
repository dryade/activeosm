source "http://rubygems.org"

# Specify your gem's dependencies in activeosm.gemspec
gemspec

gem "postgis_adapter", :git => 'git://github.com/dryade/postgis_adapter.git'

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'

  group :linux do
    gem 'rb-inotify'
    gem 'libnotify'
  end
end
