# frozen_string_literal: true

# Rakefile
require 'rake'
require 'dotenv/tasks'
require 'dotenv-heroku/tasks'

namespace :scss do
  task :watch do
    command = 'sass --watch scss:public/css --style compressed'
    `#{command}`
  end
end

# RSpec Tests
# https://www.relishapp.com/rspec/rspec-core/docs/command-line/rake-task
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end
