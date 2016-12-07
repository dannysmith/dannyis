module DannyIs
  # Dummy objects to demonstrate that MongoDB is hooked up and working. All seems to be good.
  class DummyThing
    include ::Mongoid::Document

    field :name, type: String
    field :detailed_description, type: String
    field :validity, type: Boolean
  end
end
