#!/usr/bin/env ruby

require 'net/http'
require 'uri'

puts "Testing form field submission fix..."
puts "=" * 50

# Get the form first to extract the authenticity token
form_uri = URI('http://localhost:3000/events/1/registrations/new')
response = Net::HTTP.get_response(form_uri)

if response.code != '200'
  puts "❌ Could not load form page"
  exit 1
end

# Extract CSRF token
csrf_token = response.body.match(/name="authenticity_token" value="([^"]+)"/)[1] rescue nil

if csrf_token.nil?
  puts "❌ Could not find CSRF token"
  exit 1
end

puts "✅ Form loaded successfully"
puts "✅ CSRF token found"

# Test form submission with properly filled mobile fields only
submit_uri = URI('http://localhost:3000/events/1/registrations')

# Create form data simulating mobile user (only mobile fields filled)
form_data = URI.encode_www_form([
  ['authenticity_token', csrf_token],
  ['registration[first_name]', 'Mobile'],
  ['registration[last_name]', 'User'], 
  ['registration[email]', 'mobile@example.com'],
  # Only submit mobile attendee data (desktop fields should be disabled by JS)
  ['registration[attendees_attributes][0][first_name]', 'John'],
  ['registration[attendees_attributes][0][last_name]', 'Doe'],   
  ['registration[attendees_attributes][0][dob]', '1990-01-01'],
  ['registration[attendees_attributes][0][category]', 'adult'],
  ['registration[attendees_attributes][0][_destroy]', '0']
])

http = Net::HTTP.new(submit_uri.host, submit_uri.port)
request = Net::HTTP::Post.new(submit_uri.path)
request['Content-Type'] = 'application/x-www-form-urlencoded'
request['Cookie'] = response['Set-Cookie'] if response['Set-Cookie']
request.body = form_data

response = http.request(request)

puts "Form submission response: #{response.code}"

case response.code
when '302'
  location = response['Location']
  puts "✅ Form submitted successfully! Redirected to: #{location}"
  
  if location.include?('/summary')
    puts "✅ Redirected to summary page as expected"
  else
    puts "⚠️  Redirected to: #{location}"
  end
  
when '422'
  puts "❌ Form validation failed"
  
  # Check what validation errors occurred
  if response.body.include?('Please fix the following errors')
    error_lines = response.body.scan(/<li><strong>.*?<\/li>|<li>.*?<\/li>/).map(&:strip)
    puts "Validation errors found:"
    error_lines.each do |error|
      puts "  - #{error}"
    end
  else
    puts "No specific validation errors found in response"
  end
  
when '200'
  if response.body.include?('Please fix the following errors')
    puts "❌ Form re-rendered with validation errors"
    
    # Extract and display specific errors
    error_section = response.body[response.body.index('Please fix the following errors')..response.body.index('</ul>', response.body.index('Please fix the following errors'))] rescue ""
    if error_section.length > 0
      error_lines = error_section.scan(/<li>.*?<\/li>/).map { |line| line.gsub(/<\/?[^>]*>/, '').strip }
      puts "Validation errors:"
      error_lines.each { |error| puts "  - #{error}" }
    end
  else
    puts "⚠️  Form returned 200 but without validation errors"
  end
  
else
  puts "❌ Unexpected response: #{response.code}"
  puts "Response body: #{response.body[0..300]}"
end

puts "\nTest completed!"
