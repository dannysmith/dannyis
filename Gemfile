# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.3'

# Ops
gem 'activesupport', '~>5.1'
gem 'dotenv', '~>2.7'
gem 'dotenv-heroku', '~>0.0'

# Sinatra
gem 'sinatra', '~>2.0'
gem 'sinatra-contrib', '~>2.0'

# Libs
gem 'httparty', '~>0.17'
gem 'mongoid', '~>7.0'
gem 'redis', '~>4.1'

# Server
gem 'foreman', '~>0.84'
gem 'puma', '~>4.2'

# Rack Middleware
gem 'rack-ssl-enforcer', '~>0.2'

# Sass
# See https://sass-lang.com/ruby-sass
gem 'sassc', '~> 2.0'

group :production do
  gem 'newrelic_rpm', '~>6.5'
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
