# frozen_string_literal: true

module DannyIs
  class MediumRecommendation
    include ::Mongoid::Document

    field :title, type: String
    field :url, type: String
    field :recommended_at, type: DateTime
  end
end
