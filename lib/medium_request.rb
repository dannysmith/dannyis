# frozen_string_literal: true
module DannyIs
  require 'httparty'
  require 'redis'

  class Medium
    attr_reader :posts

    # Use Redis to cache repsonses from medium
    # Will connect to the redis instance that REDIS_URL is set to.
    @@redis = Redis.new

    # username = medium username
    # image_size = the image size to pull down (for article banner images)
    # limit = the number of articles to get
    def initialize(username:, image_size: 800, limit: 1000)
      image_url = "https://cdn-images-1.medium.com/max/#{image_size}"
      @posts = []

      # Get and Parse response
      @response = JSON.parse(get_posts_via_cache(username, limit, ttl: 30))

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
    end

    private

    def get_posts_via_cache(username, limit, ttl: 300)
      # Get cached copy from redis, or make request and cache a copy
      cached_copy = @@redis.get username
      if cached_copy
        return cached_copy
      else
        response = HTTParty.get("https://medium.com/@#{username}/latest?limit=#{limit}", headers: { 'Accept': 'application/json' })
        response = response.body[16..-1] # Strips weird characters Medium add on

        # Only set the record if it already exists (just for safety), and expire the record after 20 seconds.
        puts "Caching Medium request for #{username} to Redis"
        @@redis.set username, response, nx: true, ex: ttl
        return response
      end
    end
  end
end
