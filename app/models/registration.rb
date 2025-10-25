class Registration < ApplicationRecord
  belongs_to :event
  has_many :attendees, dependent: :destroy

  accepts_nested_attributes_for :attendees, allow_destroy: true

  STATUSES = %w[pending paid canceled].freeze

  validates :first_name, :last_name, :email, presence: true
  validates :status, inclusion: { in: STATUSES }

  monetize :total_cents, with_model_currency: :currency

  def mark_paid!(payment_intent_id:)
    transaction do
      update!(status: "paid", stripe_payment_intent_id: payment_intent_id, paid_at: Time.current)
      
      # Send invoice email automatically after successful payment
      InvoiceMailer.send_invoice(self).deliver_now
    end
  rescue => e
    # Log the error but don't fail the payment marking
    Rails.logger.error "Failed to send invoice email for registration #{id}: #{e.message}"
    # Still mark as paid even if email fails
    update!(status: "paid", stripe_payment_intent_id: payment_intent_id, paid_at: Time.current) if status != 'paid'
  end
end
