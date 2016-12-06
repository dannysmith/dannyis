# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'
require 'sinatra/base'
require 'sinatra/content_for'
require 'rack/ssl-enforcer'

# Enable ruby garbage collection profiler, for New Relic
GC::Profiler.enable

# Load environment variables and libraries
Dotenv.load
Dir[File.dirname(__FILE__) + '/lib/*'].each { |f| require f }

require './dannyis'

if ENV['RACK_ENV'] == 'development'
  require 'rb-readline'
  require 'pry'
elsif ENV['RACK_ENV'] == 'production'
  use Rack::Deflater # Enable GZip Compression
end

run DannyIs::App
