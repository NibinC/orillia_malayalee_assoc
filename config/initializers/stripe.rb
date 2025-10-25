# config/initializers/stripe.rb

Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
STRIPE_PUBLIC_KEY = Rails.application.credentials.dig(:stripe, :public_key)