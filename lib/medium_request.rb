# frozen_string_literal: true
module DannyIs
  require 'httparty'
  require 'redis'

  class Medium
    @@redis_cache_ttl = 1200
    @@redis = Redis.new timeout: 60

    def self.posts(username:, limit:, image_size:)
      cached_posts = @@redis.get "#{username}-latest"

      if cached_posts
        posts = JSON.parse(cached_posts, symbolize_names: true)
      else
        image_url = "https://cdn-images-1.medium.com/max/#{image_size}"
        posts = get_posts(username, limit, image_url)
        @@redis.set "#{username}-latest", posts.to_json, nx: true, ex: @@redis_cache_ttl
      end

      posts.each do |post|
        post[:published_at] = Date.strptime((post[:published_at].to_f / 1000).to_s, '%s')
      end
    end

    def self.highlights(username:, limit:)
      cached_highlights = @@redis.get "#{username}-highlights"
      if cached_highlights
        return JSON.parse(cached_highlights, symbolize_names: true)
      else
        highlights = get_highlights(username, limit)
        @@redis.set "#{username}-highlights", highlights.to_json, nx: true, ex: @@redis_cache_ttl
        return highlights
      end
    end


    def self.set(cache_ttl:)
      @@redis_cache_ttl = cache_ttl
      puts "Redis TTL set to: #{@@redis_cache_ttl}"
    end


    # Private methods available to class methods
    class << self
      private

      def get_posts(username, limit, image_url)
        posts = []
        response = JSON.parse(call_api(username, 'latest', limit))
        response['payload']['references']['Post'].each do |id, value|
          post = {
            id: id,
            title: value['title'],
            url: "https://medium.com/@#{username}/" + value['uniqueSlug'],
            published_at: value['latestPublishedAt']
          }
          begin
            post[:image_url] = image_url + '/' + value['previewContent']['bodyModel']['paragraphs'][0]['metadata']['id']
          rescue NoMethodError
            post[:image_url] = nil
          end
          posts << post
        end
        return posts
      end

      def get_highlights(username, limit)
        highlights = []
        response = JSON.parse(call_api(username, 'highlights', limit))
        response['payload']['references']['Quote'].each do |id, value|
          post_id = value['postId']
          creator_id = response['payload']['references']['Post'][post_id]['creatorId']
          post_slug = response['payload']['references']['Post'][post_id]['uniqueSlug']
          user_url = 'https://medium.com/' + response['payload']['references']['User'][creator_id]['username']

          text = value['paragraphs'][0]['text']
          word_count = text.split(' ').size

          begin
            text.insert value['endOffset'], "</span>"
            text.insert value['startOffset'], "<span class=\"medium_markup\">"
          rescue IndexError
            # Rescue instances where the endOffset is bigger than the length of the string.
            # This has to do with Emojis that aren't actually a single glyph.
            # Just don't inject the highlight if this happens!
            text = value['paragraphs'][0]['text']
          end

          highlight = {
            id: id,
            post_id: post_id,
            creator_id: creator_id,
            text: text,
            url: "#{user_url}/#{post_slug}",
            word_count: word_count
          }
          highlights << highlight
        end
        return highlights
      end

      def call_api(username, path, limit)
        response = HTTParty.get("https://medium.com/@#{username}/#{path}?limit=#{limit}", headers: { 'Accept': 'application/json' })
        response.body[16..-1] # Strips weird characters Medium add on
      end
    end
  end
end
