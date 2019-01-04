# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.0'

# Ops
gem 'activesupport', '~>5.1'
gem 'dotenv', '~>2.2'
gem 'dotenv-heroku', '~>0.0'

# Sinatra
gem 'sinatra', '~>2.0'
gem 'sinatra-contrib', '~>2.0'

# Libs
gem 'httparty', '~>0.15'
gem 'mongoid', '~>6.2'
gem 'redis', '~>4.0'

# Server
gem 'foreman', '~>0.84'
gem 'puma', '~>3.10'

# Rack Middleware
gem 'rack-ssl-enforcer', '~>0.2'

# Modules
gem 'sass', '~>3.5'

group :production do
  gem 'newrelic_rpm', '~>5.6'
end

group :test do
  gem 'rspec', '~>3.7'
end

# rubocop:disable OrderedGems
group :development do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rb-readline'
  gem 'pry'
  gem 'rubocop'
end
