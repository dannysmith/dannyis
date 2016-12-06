# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.3.3'

# Ops
gem 'activesupport'
gem 'dotenv'
gem 'dotenv-heroku'

# Sinatra
gem 'sinatra'
gem 'sinatra-contrib'

# Libs
gem 'httparty'

# Server
gem 'foreman'
gem 'puma'

# Rack Middleware
gem 'rack-ssl-enforcer'

# Modules
gem 'pygments.rb'
gem 'redcarpet'
gem 'sass'

group :production do
  gem 'newrelic_rpm'
end

group :test do
  gem 'factory_girl'
  gem 'rspec'
end

# rubocop:disable OrderedGems
group :development do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rb-readline'
  gem 'pry'
  gem 'rerun'
  gem 'rubocop'
end
