# frozen_string_literal: true

# Rakefile
require 'rake'
require 'dotenv/tasks'
require 'dotenv-heroku/tasks'
require 'rspec/core/rake_task'

namespace :scss do
  task :watch do
    command = 'sass --watch scss:public/css --style compressed'
    `#{command}`
  end
end
