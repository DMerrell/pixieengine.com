class Tilemap < ActiveRecord::Base
  belongs_to :parent, :class_name => "Tilemap"

  has_many :map_tiles

  accepts_nested_attributes_for :map_tiles

  has_attached_file :data, S3_OPTS.merge(
    :path => "tilemaps/:id/data.:extension"
  )

  attr_accessor :data_string

  before_validation :handle_data

  def handle_data
    if data_string
      io = StringIO.new(data_string)

      io.original_filename = "data.json"
      io.content_type = "application/json"

      self.data = io
    end
  end
end
