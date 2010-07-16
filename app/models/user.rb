class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_email_field :no_connected_sites?
    config.validate_password_field :no_connected_sites?
    config.require_password_confirmation = false
  end

  include ExampleProfile
  include Commentable

  has_many :collections
  has_many :sprites

  attr_accessible :display_name, :email, :password

  after_create do
    Notifier.welcome_email(self).deliver unless email.blank?
  end

  def to_s
    display_name
  end

  def send_forgot_password_email
    Notifier.forgot_password(self).deliver
  end

  def add_to_collection(item, collection_name="favorites")
    unless collection = collections.find_by_name(collection_name)
      collection = collections.create :name => collection_name
    end

    collection.collection_items.create(:item => item)
  end

  def remove_from_collection(item, collection_name="favorites")
    if collection = collections.find_by_name(collection_name)
      collection.collection_items.find_by_item(item).each(&:destroy)
    end
  end

  def remove_favorite(sprite)
    remove_from_collection(sprite)
  end

  def favorite?(sprite)
    collections.find_or_create_by_name("favorites").collection_items.find_by_item(sprite).first
  end

  def broadcast(message)
    if Rails.env.development?
      logger.info("USER[#{id}] BROADCASTING: #{message}")
      return
    end

    if twitter = authenticated_with?(:twitter)
      twitter.post("/statuses/update.json",
        "status" => message
      )
    end
  end

  def display_name
    if super.blank?
      "Anonymous#{id}"
    else
      super
    end
  end

  private

  def no_connected_sites?
    authenticated_with.length == 0
  end
end
