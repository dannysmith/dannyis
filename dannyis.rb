# frozen_string_literal: true

module DannyIs
  class App < Sinatra::Base
    use Rack::MethodOverride # Required for put delete etc
    helpers Sinatra::ContentFor

    # -------------------------- CONFIG ------------------------- #

    configure do
      # Use SSL Enforcer
      use Rack::SslEnforcer, only_hosts: ENV['BASE_DOMAIN']
      set :session_secret, 'asdfa2342923422f1adc05c837fa234230e3594b93824b00e930ab0fb94b'

      # Enable sinatra sessions
      use Rack::Session::Cookie, key: '_rack_session',
                                 path: '/',
                                 expire_after: 2_592_000, # In seconds
                                 secret: settings.session_secret

      # Load Mongoid
      Mongoid.load!('mongoid.yml')
    end

    configure :development do
      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = __dir__
    end

    configure :production do
      require 'newrelic_rpm'
    end

    helpers do
      def h(text)
        Rack::Utils.escape_html(text)
      end
    end

    before do
      # Switch on Caching
      cache_control :public, :must_revalidate, max_age: 60 if ENV['RACK_ENV'] == 'production'

      # Make medium reccomendations available in all views
      @medium_recommendations = DannyIs::MediumRecommendation.limit(8).order_by(recommended_at: :desc)
    end

    # ------------------------ Site Pages ---------------------- #

    get '/' do
      erb :home
    end

    # get '/pry' do
    #   binding.pry
    # end

    # ------------------------ Webhook Endpoints ---------------------- #

    # Configure an IFTTT Recipe whhich POSTs the following JSON to this endpoint
    #   using the 'Make' channel.
    #   The key is an arbitry string, which must match the key contained in the
    #   IFTTT_POST_TOKEN env var.
    #
    # {
    #   "key": "xxxxxx",
    #   "recommendedAt": "{{RecommendedAt}}",
    #   "postURL": "{{PostUrl}}",
    #   "postTitle": "{{PostTitle}}"
    # }
    post '/webhooks/medium-recommendation' do
      data = JSON.parse request.body.read
      if data['key'] == ENV['IFTTT_POST_TOKEN']
        puts 'Recieved Recomendation from Medium'
        DannyIs::MediumRecommendation.create! title: data['postTitle'], recommended_at: data['recommendedAt'], url: data['postURL']
        status 200
      else
        status 403
      end
    end

    # ----------------------------- Blog --------------------------- #

    # -------------------------- RSS Feeds ------------------------ #

    # ------------------------- JSON Routes ----------------------- #

    # -------------------------- Redirects ------------------------ #

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
