# frozen_string_literal: true

module DannyIs
  class App < Sinatra::Base
    use Rack::MethodOverride # Required for put delete etc
    helpers Sinatra::ContentFor

    # -------------------------- CONFIG ------------------------- #

    configure do
      # Use SSL Enforcer
      use Rack::SslEnforcer, :only_hosts => ENV['BASE_DOMAIN']
      set :session_secret, 'asdfa2342923422f1adc05c837fa234230e3594b93824b00e930ab0fb94b'

      #Enable sinatra sessions
      use Rack::Session::Cookie, :key => '_rack_session',
                                 :path => '/',
                                 :expire_after => 2592000, # In seconds
                                 :secret => settings.session_secret
    end

    configure :development do
      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = __dir__
    end

    configure :production do
      require 'newrelic_rpm'
    end

    before do
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
      when %r{^\/instagraming\/?}
        puts 'Redirecting to instagram'
        redirect 'https://instagram.com/dannysmith', 301
      when %r{^\/noting\/?}
        puts 'Redirecting to notes.danny.is'
        redirect 'http://notes.danny.is', 301
      when %r{^\/tweeting\/?}
        puts 'Redirecting to twitter'
        redirect 'https://twitter.com/dannysmith', 301
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
