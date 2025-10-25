module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

      event = nil
      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      rescue JSON::ParserError, Stripe::SignatureVerificationError
        return head :bad_request
      end

      case event['type']
      when 'checkout.session.completed'
        session = event['data']['object']
        registration_id = session['metadata']['registration_id']
        payment_intent = session['payment_intent']
        Registration.find(registration_id)&.mark_paid!(payment_intent_id: payment_intent)
      end

      head :ok
    end
  end
end
