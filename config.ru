# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'
require 'sinatra/base'
require 'sinatra/content_for'
require 'net/http'
require 'yaml'
require 'redcarpet'

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
