source "http://rubygems.org"

gem "rails", "~> 3.2.9"

# jquery-rails is used by the dummy application
gem "jquery-rails"

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem "rspec-rails", :group => [:test, :development]

group :development do
  gem 'guard'
  gem 'guard-bundler'
  gem 'yard'
  gem 'growl'
  gem 'ruby_gntp'
  gem 'travis-lint'
end

group :test do
  gem "rake"
  gem "guard-rspec"
  gem "rb-fsevent"
  gem "activerecord"
  gem "mysql2"
  gem "ruby-pg"
end
# To use debugger
# gem 'debugger'
