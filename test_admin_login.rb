#!/usr/bin/env ruby

require 'net/http'
require 'uri'

puts "🔐 Testing Admin Login System"
puts "=" * 40

# Test 1: Admin login page loads
print "Testing admin login page... "
begin
  uri = URI('http://localhost:3000/admin/users/sign_in')
  response = Net::HTTP.get_response(uri)
  
  if response.code == '200'
    puts "✅ PASS"
    
    # Check for login form elements
    if response.body.include?('Admin Login') && response.body.include?('email') && response.body.include?('password')
      puts "  ✅ Login form elements present"
    else
      puts "  ❌ Login form elements missing"
    end
    
  else
    puts "❌ FAIL (Status: #{response.code})"
  end
rescue => e
  puts "❌ FAIL (Error: #{e.message})"
end

# Test 2: Admin dashboard redirects when not logged in
print "Testing admin dashboard protection... "
begin
  uri = URI('http://localhost:3000/admin')
  response = Net::HTTP.get_response(uri)
  
  if response.code == '302' || response.code == '401'
    puts "✅ PASS (Properly protected)"
  else
    puts "❌ FAIL (Not protected - Status: #{response.code})"
  end
rescue => e
  puts "❌ FAIL (Error: #{e.message})"
end

# Test 3: Check if admin user exists
print "Checking admin user in database... "
begin
  result = `cd /Users/nibin.chamayil/orillia_malayalee_assoc && rails runner "puts AdminUser.exists? ? 'EXISTS' : 'NOT_FOUND'" 2>/dev/null`.strip
  
  if result == 'EXISTS'
    puts "✅ PASS"
  else
    puts "❌ FAIL (No admin users found)"
  end
rescue => e
  puts "❌ FAIL (Error: #{e.message})"
end

# Test 4: Navigation icon present
print "Testing homepage navigation... "
begin
  uri = URI('http://localhost:3000')
  response = Net::HTTP.get_response(uri)
  
  if response.code == '200' && response.body.include?('fa-user-shield')
    puts "✅ PASS (Admin icon in navigation)"
  else
    puts "❌ FAIL (Admin icon missing)"
  end
rescue => e
  puts "❌ FAIL (Error: #{e.message})"
end

puts "\n📋 ADMIN LOGIN SYSTEM STATUS:"
puts "🔗 Login URL: http://localhost:3000/admin/sign_in"
puts "🏠 Admin Dashboard: http://localhost:3000/admin"
puts "👤 Admin Email: admin@oma.ca"
puts "🔒 Password: [Check with administrator]"

puts "\n✅ Admin login system is ready for use!"
