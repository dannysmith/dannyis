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

    get '/writing/?' do
      @articles = DannyIs::Medium::Request.new(username: 'dannysmith', image_size: 1200, limit: 1000).posts
      erb :writing
    end

    get '/singing/?' do
      @videos = [
        {title: 'Death Letter Blues', code: 'q3M-JhOybh4'},
        {title: 'Grinning in Your Face', code: 'c1wWDMMq_nM'},
        {title: 'Spiritual Song', code: 'x5-FUNYbjug'},
        {title: 'Goin\' Down Slow', code: '31R4N3pmbmQ'},
        {title: 'D-Day Blues', code: 'p9u_P4qVy_I'},
        {title: 'Travelling Riverside Blues', code: 'uZxmML7vzHE'}
      ]
      erb :singing
    end

    get '/reading/?' do
      @pocket_links = DannyIs::PocketItem.all.order_by(recommended_at: :desc)
      @medium_recommendations = DannyIs::MediumRecommendation.order_by(recommended_at: :desc)
      # TODO: Merge the pocket links and the medium links into one big list, but display thnem differently
      @links = @pocket_links
      erb :reading
    end

    # get '/pry' do
    #   binding.pry
    # end

    # ------------------------ Webhook Endpoints ---------------------- #

    # Medium Recomendations
    # ---------------------
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

    # Pocket Items
    # ------------
    # Configure an IFTTT Recipe whhich POSTs the following JSON to this endpoint
    #   using the 'Make' channel.
    #   The key is an arbitry string, which must match the key contained in the
    #   IFTTT_POST_TOKEN env var.
    #
    # {
    #   "key": "xxxxxx",
    #   "title": "{{Title}}",
    #   "url": "{{Url}}",
    #   "excerpt": "{{Excerpt}}",
    #   "tags": "{{Tags}}",
    #   "imageURL": "{{ImageUrl}}",
    #   "addedAt": "{{AddedAt}}"
    # }
    post '/webhooks/pocket-archive' do
      data = JSON.parse request.body.read
      if data['key'] == ENV['IFTTT_POST_TOKEN']
        puts 'Recieved Archived Item from Pocket'
        DannyIs::PocketItem.create! title: data['title'],
                                    url: data['url'],
                                    excerpt: data['excerpt'],
                                    image_url: data['imageURL'],
                                    tags: data['tags'],
                                    added_at: data['addedAt']
        status 200
      else
        status 403
      end
    end

    # ----------------------------- Blog --------------------------- #

    # -------------------------- RSS Feeds ------------------------ #

    # ------------------------- JSON Routes ----------------------- #

    # -------------------------- Redirects ------------------------ #

    get '/noting/?' do
      puts 'Redirecting to notes.danny.is'
      redirect 'http://notes.danny.is', 301
    end

    get(//) do
      path = request.path_info
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

    not_found do
      status 404
      erb :e404
    end
  end
end
