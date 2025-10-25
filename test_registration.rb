#!/usr/bin/env ruby
require_relative 'config/environment'

registration = Registration.find(2)
event = registration.event

puts "Registration found: #{registration.first_name} #{registration.last_name}"
puts "Event: #{event.name}"
puts "Adult price: #{event.adult_price_cents}"
puts "Minor price: #{event.minor_price_cents}"
puts "Attendees: #{registration.attendees.count}"
registration.attendees.each do |attendee|
  puts "  - #{attendee.first_name} #{attendee.last_name} (#{attendee.category})"
end
puts "Stripe public key: #{STRIPE_PUBLIC_KEY[0..20]}..."
puts "Total cents: #{registration.total_cents}"
