class CheckoutsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  
  def create
    Rails.logger.info "CheckoutsController#create called with params: #{params.inspect}"
    Rails.logger.info "Content-Type: #{request.content_type}"
    Rails.logger.info "Headers: #{request.headers.to_h.select { |k,v| k.start_with?('HTTP_') }}"
    
    registration = Registration.find(params[:registration_id])
    event = registration.event

    line_items = []
    adult_count = registration.attendees.count { |a| a.category == "adult" }
    minor_count = registration.attendees.count { |a| a.category == "minor" }

    if adult_count > 0
      line_items << {
        price_data: {
          currency: event.currency.downcase,
          product_data: { name: "#{event.name} – Adult Ticket" },
          unit_amount: event.adult_price_cents
        },
        quantity: adult_count
      }
    end

    if minor_count > 0
      line_items << {
        price_data: {
          currency: event.currency.downcase,
          product_data: { name: "#{event.name} – Minor Ticket" },
          unit_amount: event.minor_price_cents
        },
        quantity: minor_count
      }
    end

    session = Stripe::Checkout::Session.create(
      mode: "payment",
      payment_method_types: ["card"],
      customer_email: registration.email,
      line_items: line_items,
      success_url: "#{Rails.application.credentials.dig(:app, :url_host)}/checkouts/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url:  "#{Rails.application.credentials.dig(:app, :url_host)}/checkouts/cancel",
      metadata: { registration_id: registration.id }
    )

    registration.update!(stripe_checkout_session_id: session.id)

    response_data = { 
      id: session.id, 
      public_key: STRIPE_PUBLIC_KEY 
    }
    Rails.logger.info "Sending response: #{response_data.inspect}"
    render json: response_data
  rescue Stripe::StripeError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: "Payment processing failed. Please try again." }, status: :unprocessable_entity
  end

  def success
    @session_id = params[:session_id]
    
    # Try to find the registration associated with this session
    if @session_id.present?
      begin
        # Retrieve session from Stripe to get registration_id from metadata
        session = Stripe::Checkout::Session.retrieve(@session_id)
        registration_id = session.metadata&.[]('registration_id')
        
        if registration_id
          @registration = Registration.find(registration_id)
          @event = @registration.event
        end
      rescue Stripe::StripeError, ActiveRecord::RecordNotFound => e
        Rails.logger.error "Error retrieving registration from session: #{e.message}"
        @registration = nil
        @event = nil
      end
    end
  end

  def cancel
  end
end
