# frozen_string_literal: true

module DannyIs
  module Medium
    require 'httparty'
    class Request
      attr_reader :posts
      def initialize(username:, image_size: 800, limit: 1000)
        image_url = "https://cdn-images-1.medium.com/max/#{image_size}"
        @posts = []
        raw = HTTParty.get("https://medium.com/@#{username}/latest?limit=#{limit}", headers: { 'Accept': 'application/json' })
        @response = JSON.parse(raw.body[16..-1])
        @response['payload']['references']['Post'].each do |id, value|
          post = {}
          post[:id] = id
          post[:title] = value['title']
          post[:url] = "https://medium.com/@#{username}/" + value['uniqueSlug']
          post[:published_at] = Date.strptime((value['latestPublishedAt'].to_f / 1000).to_s, '%s')
          begin
            post[:image_url] = image_url + '/' + value['previewContent']['bodyModel']['paragraphs'][0]['metadata']['id']
          rescue NoMethodError
            post[:image_url] = nil
          end
          @posts << post
        end
      end
    end
  end
end
