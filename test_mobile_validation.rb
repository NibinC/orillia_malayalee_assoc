#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

# Test mobile form validation fix
puts "Testing mobile form validation fix..."
puts "=" * 50

# Test that the registration form loads without errors
begin
  uri = URI('http://localhost:3000/events/1/registrations/new')
  response = Net::HTTP.get_response(uri)
rescue => e
  puts "Error connecting to server: #{e.message}"
  exit 1
end

puts "Form page status: #{response.code}"

if response.code == '200'
  # Check if our JavaScript improvements are in the page
  body = response.body
  
  checks = {
    'Form ID present' => body.include?('id="registration-form"'),
    'Mobile layout present' => body.include?('d-md-none'),
    'Desktop layout present' => body.include?('d-none d-md-flex'),
    'Visibility check function' => body.include?('isElementVisible'),
    'Dynamic required fields' => body.include?('updateRequiredFields'),
    'Mobile CSS present' => body.include?('touch-action: manipulation')
  }
  
  checks.each do |check, result|
    status = result ? "✅ PASS" : "❌ FAIL"
    puts "#{check}: #{status}"
  end
  
  # Count attendee fields to verify dual layout structure
  mobile_fields = body.scan(/d-md-none.*?first_name.*?form-control/).length
  desktop_fields = body.scan(/d-none d-md-flex.*?first_name.*?form-control/).length
  
  puts "\nForm structure:"
  puts "Mobile attendee fields: #{mobile_fields}"
  puts "Desktop attendee fields: #{desktop_fields}"
  
  if mobile_fields > 0 && desktop_fields > 0
    puts "✅ Dual layout structure confirmed"
  else
    puts "❌ Dual layout structure issue detected"
  end
  
else
  puts "❌ Form page failed to load: #{response.code}"
  puts response.body[0..500] if response.body
end

puts "\nTest completed!"
