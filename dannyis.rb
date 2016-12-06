# frozen_string_literal: true

module DannyIs
  class App < Sinatra::Base
    use Rack::MethodOverride # Required for put delete etc
    helpers Sinatra::ContentFor

    # -------------------------- CONFIG ------------------------- #

    configure :development do
      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = __dir__
    end

    configure :production do
      require 'newrelic_rpm'
    end

    before do
      # if ENV['RACK_ENV'] == 'production'
      #   unless request.secure?
      #     puts "Redirecting to HTTPS: #{request.url.sub('http', 'https')}"
      #     redirect request.url.sub('http', 'https'), 301
      #   end
      # end

      # Switch on Caching
      cache_control :public, :must_revalidate, max_age: 60 if ENV['RACK_ENV'] == 'production'
    end

    # ------------------------ Site Pages ---------------------- #

    get '/' do
      erb :home
    end

    # ----------------------------- Blog --------------------------- #

    # -------------------------- RSS Feeds ------------------------ #

    # ------------------------- JSON Routes ----------------------- #

    # -------------------------- Redirects ------------------------ #

    # rubocop:disable BlockLength
    get(//) do
      path = request.path_info
      case path
      when %r{^/cv(?:/|\.pdf)?$}
        puts 'Redirecting to CV'
        redirect 'http://files.dasmith.co.uk/cv.pdf', 301
      when %r{^\/files(.*)}
        puts "Redirecting to http://files.dasmith.co.uk/files#{$1}"
        redirect "http://files.dasmith.co.uk/files#{$1}", 301
      when %r{^\/instagraming\/?}
        puts 'Redirecting to instagram'
        redirect 'http://instagram.com/dannysmith', 301
      when %r{^\/noting\/?}
        puts 'Redirecting to notes.danny.is'
        redirect 'http://notes.danny.is', 301
      when %r{^\/tweeting\/?}
        puts 'Redirecting to twitter'
        redirect 'http://twitter.com/dannysmith', 301
      else
        puts "Trying redirect to CloudApp: #{path}"
        # Try a redirect to CloudApp
        if [200, 301].include? Net::HTTP.get_response('c.danny.is', path).code.to_i
          puts 'Redirecting to CloudApp'
          redirect "http://c.danny.is#{path}"
        else
          puts 'No CloudApp resource found'
          status 404
          erb :e404
        end
      end
    end

    not_found do
      status 404
      erb :e404
    end
  end
end
