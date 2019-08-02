# frozen_string_literal: true

# Rakefile
require 'rake'
require 'dotenv/tasks'
require 'dotenv-heroku/tasks'

# RSpec Tests
# https://www.relishapp.com/rspec/rspec-core/docs/command-line/rake-task
# rubocop:disable HandleExceptions
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end
