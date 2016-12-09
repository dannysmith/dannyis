# frozen_string_literal: true

module DannyIs
  class PocketItem
    include ::Mongoid::Document

    field :title, type: String
    field :url, type: String
    field :excerpt, type: String
    field :tags, type: String
    field :image_url, type: String
    field :added_at, type: DateTime
  end
end
