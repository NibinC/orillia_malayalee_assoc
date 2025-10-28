#!/usr/bin/env ruby

require 'net/http'
require 'uri'

puts "Testing mobile form submission validation..."
puts "=" * 50

# Get the form first to extract the authenticity token
form_uri = URI('http://localhost:3000/events/1/registrations/new')
form_response = Net::HTTP.get_response(form_uri)

if form_response.code != '200'
  puts "❌ Could not load form page"
  exit 1
end

# Extract CSRF token
csrf_token = form_response.body.match(/name="authenticity_token" value="([^"]+)"/)[1] rescue nil

if csrf_token.nil?
  puts "❌ Could not find CSRF token"
  exit 1
end

puts "✅ Form loaded successfully"
puts "✅ CSRF token found: #{csrf_token[0..10]}..."

# Test form submission with missing fields (should trigger validation)
submit_uri = URI('http://localhost:3000/events/1/registrations')

# Create form data with missing attendee info (should fail validation)
form_data = URI.encode_www_form([
  ['authenticity_token', csrf_token],
  ['registration[first_name]', 'John'],
  ['registration[last_name]', 'Doe'], 
  ['registration[email]', 'john@example.com'],
  ['registration[attendees_attributes][0][first_name]', ''],  # Empty - should cause validation error
  ['registration[attendees_attributes][0][last_name]', ''],   # Empty - should cause validation error  
  ['registration[attendees_attributes][0][dob]', ''],         # Empty - should cause validation error
  ['registration[attendees_attributes][0][category]', 'adult'],
  ['registration[attendees_attributes][0][_destroy]', '0']
])

http = Net::HTTP.new(submit_uri.host, submit_uri.port)
request = Net::HTTP::Post.new(submit_uri.path)
request['Content-Type'] = 'application/x-www-form-urlencoded'
request['Cookie'] = form_response['Set-Cookie'] if form_response['Set-Cookie']
request.body = form_data

response = http.request(request)

puts "Form submission response: #{response.code}"

if response.code == '422' || response.code == '200'
  if response.body.include?('Please fix the following errors')
    puts "✅ Server-side validation working - errors detected"
    
    # Count error messages
    error_count = response.body.scan(/Please fix the following errors/).length
    puts "Error sections found: #{error_count}"
    
    if response.body.include?("first name can't be blank")
      puts "✅ First name validation working"
    end
    
    if response.body.include?("last name can't be blank")  
      puts "✅ Last name validation working"
    end
    
    if response.body.include?("dob can't be blank")
      puts "✅ Date of birth validation working"  
    end
    
  else
    puts "❌ Expected validation errors not found"
    puts "Response excerpt: #{response.body[0..500]}"
  end
else
  puts "❌ Unexpected response code: #{response.code}"
  puts "Response: #{response.body[0..200]}"
end

puts "\nForm validation test completed!"
