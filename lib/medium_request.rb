# frozen_string_literal: true
module DannyIs
  require 'httparty'
  require 'redis'

  class Medium
    attr_reader :posts, :highlights

    # Use Redis to cache repsonses from medium
    # Will connect to the redis instance that REDIS_URL is set to.
    @@redis = Redis.new timeout: 60

    # username = medium username
    # image_size = the image size to pull down (for article banner images)
    # limit = the number of articles to get
    def initialize(username:, image_size: 800, article_limit: 1000, highlight_limit: 50)
      image_url = "https://cdn-images-1.medium.com/max/#{image_size}"
      @posts = []
      @highlights = []

      # Posts

      @response = JSON.parse(get_data_via_cache(username, path: 'latest', limit: article_limit, ttl: 1800))

      @response['payload']['references']['Post'].each do |id, value|
        post = {
          id: id,
          title: value['title'],
          url: "https://medium.com/@#{username}/" + value['uniqueSlug'],
          published_at: Date.strptime((value['latestPublishedAt'].to_f / 1000).to_s, '%s')
        }
        begin
          post[:image_url] = image_url + '/' + value['previewContent']['bodyModel']['paragraphs'][0]['metadata']['id']
        rescue NoMethodError
          post[:image_url] = nil
        end
        @posts << post
      end

      # Highlights

      @response = JSON.parse(get_data_via_cache(username, path: 'highlights', limit: highlight_limit, ttl: 1800))

      @response['payload']['references']['Quote'].each do |id, value|
        post_id = value['postId']
        creator_id = @response['payload']['references']['Post'][post_id]['creatorId']
        post_slug = @response['payload']['references']['Post'][post_id]['uniqueSlug']
        user_url = 'https://medium.com/' + @response['payload']['references']['User'][creator_id]['username']
        highlight = {
          id: id,
          post_id: post_id,
          creator_id: creator_id,
          text: value['paragraphs'][0]['text'],
          url: "#{user_url}/#{post_slug}"
        }
        @highlights << highlight
      end
    end

    private

    def get_data_via_cache(username, path:, limit:, ttl: 300)
      # Get cached copy from redis, or make request and cache a copy
      cached_copy = @@redis.get "#{username}-#{path}"
      if cached_copy
        return cached_copy
      else
        response = HTTParty.get("https://medium.com/@#{username}/#{path}?limit=#{limit}", headers: { 'Accept': 'application/json' })
        response = response.body[16..-1] # Strips weird characters Medium add on

        # Only set the record if it already exists (just for safety), and expire the record after 20 seconds.
        puts "Caching Medium request for #{username}/#{path} to Redis"
        @@redis.set "#{username}-#{path}", response, nx: true, ex: ttl
        return response
      end
    end
  end
end
