module DannyIs
  # Dummy objects to demonstrate how MongoDB is hooked up
  class DummyThing
    include ::Mongoid::Document

    field :name, type: String
    field :detailed_description, type: String
    field :validity, type: Boolean
  end
end
