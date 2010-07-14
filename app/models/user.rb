class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_email_field :no_connected_sites?
    config.validate_password_field :no_connected_sites?
    config.require_password_confirmation = false
  end

  include ExampleProfile

  has_many :sprites
  has_many :favorites

  attr_accessible :display_name, :email, :password

  after_create do
    Notifier.welcome_email(self).deliver unless email.blank?
  end

  def to_s
    display_name
  end

  def remove_favorite(sprite)
    favorites.find_by_sprite_id(sprite.id).destroy
  end

  def favorite?(sprite)
    favorites.find_by_sprite_id sprite.id
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
