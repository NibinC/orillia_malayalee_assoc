#!/usr/bin/env ruby
# Test script to verify age calculation logic

require_relative 'config/environment'

puts "🧪 Testing Age-Based Category Calculation"
puts "=" * 50

# Test cases
test_cases = [
  { name: "5-year-old child", dob: Date.new(2020, 1, 1), expected: "minor" },
  { name: "11-year-old child", dob: Date.new(2014, 1, 1), expected: "minor" },
  { name: "12-year-old (exactly 12)", dob: Date.new(2013, 10, 25), expected: "adult" },
  { name: "13-year-old teen", dob: Date.new(2012, 1, 1), expected: "adult" },
  { name: "25-year-old adult", dob: Date.new(2000, 1, 1), expected: "adult" },
  { name: "Baby (1 year old)", dob: Date.new(2024, 1, 1), expected: "minor" }
]

puts "Current date: #{Date.current}"
puts

test_cases.each do |test_case|
  attendee = Attendee.new(
    first_name: "Test",
    last_name: "Person",
    dob: test_case[:dob],
    registration: Registration.new
  )
  
  # Trigger validation to calculate category
  attendee.valid?
  
  age = attendee.age
  category = attendee.category
  status = category == test_case[:expected] ? "✅ PASS" : "❌ FAIL"
  
  puts "#{status} | #{test_case[:name]:<20} | DOB: #{test_case[:dob]} | Age: #{age} | Category: #{category} | Expected: #{test_case[:expected]}"
end

puts
puts "🎯 Age Calculation Rules:"
puts "   - Minor: Under 12 years old"
puts "   - Adult: 12 years and older"
puts
puts "💡 The category is automatically calculated when:"
puts "   - Creating a new attendee with DOB"
puts "   - Updating an existing attendee's DOB"
puts "   - Form submission (JavaScript also handles real-time calculation)"
