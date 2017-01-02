# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.4.0'

# Ops
gem 'activesupport', '~>5.0'
gem 'dotenv', '~>2.1'
gem 'dotenv-heroku', '~>0.0'

# Sinatra
gem 'sinatra', '~>1.4'
gem 'sinatra-contrib', '~>1.4'

# Libs
gem 'httparty', '~>0.14'
gem 'mongoid', '~>6.0'
gem 'redis', '~>3.2'

# Server
gem 'foreman', '~>0.82'
gem 'puma', '~>3.6'

# Rack Middleware
gem 'rack-ssl-enforcer', '~>0.2'

# Modules
gem 'sass', '~>3.4'

group :production do
  gem 'newrelic_rpm', '~>3.17'
end

group :test do
  gem 'rspec', '~>3.5'
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
