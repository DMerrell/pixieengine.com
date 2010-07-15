class Collection < ActiveRecord::Base
  belongs_to :user
  has_many :collection_items

  def items
    collection_items.map(&:item)
  end
end
