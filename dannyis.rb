# frozen_string_literal: true

module DannyIs
  # rubocop:disable ClassLength
  class App < Sinatra::Base
    # -------------------------- CONFIG ------------------------- #

    configure do
      # Required for put delete etc
      use Rack::MethodOverride

      # Enable ContentFor
      helpers Sinatra::ContentFor

      # Use SSL Enforcer
      use Rack::SslEnforcer, only_hosts: ENV.fetch('BASE_DOMAIN')
      set :session_secret, ENV.fetch('SESSION_SECRET')

      # Enable sinatra sessions
      use Rack::Session::Cookie, key: '_rack_session',
                                 path: '/',
                                 expire_after: 2_592_000, # In seconds
                                 secret: settings.session_secret

      # Set TTL for cached medium objects
      DannyIs::Medium.set cache_ttl: 1800

      # Load Mongoid
      Mongoid.load!('mongoid.yml')
    end

    configure :development do
      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = __dir__
    end

    configure :production do
      # Enable NewRelic
      require 'newrelic_rpm'
    end

    # -------------------------- HELPERS ------------------------- #

    helpers do
      def h(text)
        Rack::Utils.escape_html(text)
      end
    end

    # ------------------------ BEFORE HOOKS ----------------------- #

    before do
      # Switch on Caching
      cache_control :public, :must_revalidate, max_age: 60 if ENV['RACK_ENV'] == 'production'
    end

    # ======================================================= #
    # ------------------------ Routes ----------------------- #
    # ======================================================= #

    # ------------------------ Site Pages ------------------- #

    get '/' do
      @medium_recommendations = DannyIs::MediumRecommendation.limit(8).order_by(recommended_at: :desc)
      erb :home
    end

    get '/writing/?' do
      @articles = DannyIs::Medium.posts(username: 'dannysmith', limit: 1000, image_size: 1200)
      erb :writing
    end

    get '/highlighting/?' do
      @highlights = DannyIs::Medium.highlights(username: 'dannysmith', limit: 30)
      erb :highlighting
    end

    get '/singing/?' do
      @videos = [
        { title: 'D-Day Blues', code: 'p9u_P4qVy_I' },
        { title: 'Travelling Riverside Blues', code: 'uZxmML7vzHE' },
        { title: 'Death Letter Blues', code: 'q3M-JhOybh4' },
        { title: 'Grinning in Your Face', code: 'c1wWDMMq_nM' },
        { title: 'Spiritual Song', code: 'x5-FUNYbjug' },
        { title: 'Goin\' Down Slow', code: '31R4N3pmbmQ' }
      ]
      erb :singing
    end

    get '/reading/?' do
      @pocket_links = DannyIs::PocketItem.all.order_by(recommended_at: :desc)
      @medium_recommendations = DannyIs::MediumRecommendation.order_by(recommended_at: :desc)

      # Cast collections into single array, then sort by recommended_at date.
      @links = Array(@medium_recommendations) + Array(@pocket_links)
      @links.sort! { |medium, pocket| pocket.recommended_at <=> medium.recommended_at }

      # TODO: Add some sort of pagination or limiting here.
      erb :reading
    end

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
                                    recommended_at: data['addedAt']
        status 200
      else
        status 403
      end
    end

    # -------------------------- Redirects ------------------------ #

    get '/noting/?' do
      puts 'Redirecting to notes.danny.is'
      redirect 'http://notes.danny.is', 301
    end

    get '/using/?' do
      puts 'Redirecting to Notion for /uses'
      redirect 'https://notion.so/dannysmith/Danny-Uses-72544bdecd144ca5ab3864d92dcd119b', 301
    end

    get '/meeting/?' do
      puts 'Redirecting to Notion for /meeting'
      redirect 'https://www.notion.so/Book-a-Meeting-with-Danny-e39fc8def5514b67b559b2e5a51934ae', 301
    end

    get '/rtotd/?' do
      puts 'Redirecting to Notion for /rtotd'
      redirect 'https://www.notion.so/dannysmith/Remote-Working-Tips-821f025d73cb4d93a661abc93822fb14', 301
    end

    get '/remote/?' do
      puts 'Redirecting to Notion for /remote'
      redirect 'https://www.notion.so/dannysmith/Remote-Working-Tips-821f025d73cb4d93a661abc93822fb14', 301
    end

    get '/`zoom`/?' do
      puts 'Redirecting to Zoom link'
      redirect 'https://zoom.us/j/6117794962?pwd=UHk1Z1JPQ0ZIVjZXNWJaL3Rsc1J4Zz09', 301
    end

    # Redirect to old article URLs.
    [
      '/writing/a-simpler-responsive-grid-120605',
      '/writing/what-is-good-design-130121',
      '/writing/mod-email-subject-lines-with-applescript-osx-130628',
      '/writing/new-job-new-website-131002',
      '/writing/switching-from-rvm-to-rbenv-131008',
      '/writing/sass-and-other-css-preprocessors-140301',
      '/writing/a-pretty-readability-archive-with-ruby-and-css-140420',
      '/writing/controlling-the-rag-with-redcarpet-140504',
      '/writing/writing-testable-code-140505',
      '/writing/replacing-bash-with-zsh-141226',
      '/writing/blogging-with-evernote-and-ruby-141226',
      '/writing/feedback-loops-150126',
      '/writing/delivering-business-kanban-and-validated-learning-150314'
    ].each do |path|
      get "#{path}/?" do
        puts "Redirecting to old site: #{path}"
        redirect "http://v1.danny.is#{path}", 301
      end
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

    get('/cv/?') do
      redirect '/cv.pdf'
    end

    get('/cv-rafac/?') do
      redirect '/cv-rafac.pdf'
    end

    not_found do
      status 404
      erb :e404
    end
  end
end
