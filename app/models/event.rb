class Event < ApplicationRecord
  has_many :registrations, dependent: :restrict_with_exception

  monetize :adult_price_cents, with_model_currency: :currency
  monetize :minor_price_cents, with_model_currency: :currency

  scope :published, -> { where(published: true) }
end
