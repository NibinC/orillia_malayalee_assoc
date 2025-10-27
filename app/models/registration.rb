class Registration < ApplicationRecord
  belongs_to :event
  has_many :attendees, dependent: :destroy

  accepts_nested_attributes_for :attendees, allow_destroy: true

  before_validation :prepare_attendees_and_total

  STATUSES = %w[pending paid canceled].freeze

  validates :first_name, :last_name, :email, presence: true
  validates :status, inclusion: { in: STATUSES }

  monetize :total_cents, with_model_currency: :currency

  def mark_paid!(payment_intent_id:)
    # First, mark as paid (this should always succeed)
    update!(status: "paid", stripe_payment_intent_id: payment_intent_id, paid_at: Time.current)
    Rails.logger.info "Registration #{id} marked as paid successfully"
    
    # Then try to send email (but don't let it fail the payment marking)
    # TODO: Temporarily disabled email sending
    # begin
    #   InvoiceMailer.send_invoice(self).deliver_now
    #   Rails.logger.info "Invoice email sent successfully for registration #{id}"
    # rescue => e
    #   # Log the error but don't fail the payment marking
    #   Rails.logger.error "Failed to send invoice email for registration #{id}: #{e.message}"
    # end
  end

  private

  def prepare_attendees_and_total
    return unless event
    # Ensure each attendee has a category based on DOB before parent validation
    attendees.each do |a|
      next if a.marked_for_destruction?
      if a.dob.present?
        age = ((Date.current - a.dob) / 365.25).floor
        a.category = age < 12 ? 'minor' : 'adult'
      end
    end
    valid_attendees = attendees.reject(&:marked_for_destruction?)
    adult_count  = valid_attendees.count { |a| a.category == 'adult' }
    minor_count  = valid_attendees.count { |a| a.category == 'minor' }
    self.total_cents = (adult_count * event.adult_price_cents) + (minor_count * event.minor_price_cents)
    self.currency = event.currency
  end
end
