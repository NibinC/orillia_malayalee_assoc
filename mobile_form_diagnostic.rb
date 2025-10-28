#!/usr/bin/env ruby

# Mobile Form Diagnostic Script
# This script checks for common issues that prevent mobile form submission

puts "🔍 Mobile Form Diagnostic"
puts "=" * 50

# Check 1: Browser Restriction
puts "\n1. Checking browser restrictions..."
begin
  require_relative 'config/environment'
  
  controller_file = File.read('app/controllers/registrations_controller.rb')
  app_controller_file = File.read('app/controllers/application_controller.rb')
  
  if controller_file.include?('allow_browser versions:')
    puts "✅ RegistrationsController has browser version override"
  elsif app_controller_file.include?('allow_browser versions: :modern')
    puts "⚠️  ApplicationController has modern browser restriction"
    puts "   This may block older mobile browsers"
  else
    puts "✅ No browser restrictions found"
  end
rescue => e
  puts "❌ Error checking browser restrictions: #{e.message}"
end

# Check 2: Form Structure
puts "\n2. Checking form structure..."
begin
  form_file = File.read('app/views/registrations/new.html.erb')
  
  if form_file.include?('form_with')
    puts "✅ Form uses form_with helper"
  else
    puts "❌ Form doesn't use form_with helper"
  end
  
  if form_file.include?('local: true')
    puts "✅ Form has local: true (no AJAX)"
  else
    puts "⚠️  Form might use AJAX (could cause mobile issues)"
  end
  
  if form_file.include?('id: "registration-form"')
    puts "✅ Form has ID for JavaScript targeting"
  else
    puts "❌ Form missing ID attribute"
  end
  
  if form_file.include?('Proceed to Summary')
    puts "✅ Submit button found"
  else
    puts "❌ Submit button not found"
  end
rescue => e
  puts "❌ Error checking form structure: #{e.message}"
end

# Check 3: Mobile CSS
puts "\n3. Checking mobile CSS..."
begin
  css_file = File.read('app/assets/stylesheets/application.css')
  
  if css_file.include?('@media (max-width: 767.98px)')
    puts "✅ Mobile CSS media queries found"
  else
    puts "⚠️  No mobile-specific CSS found"
  end
  
  if css_file.include?('input[type="submit"]')
    puts "✅ Submit button mobile styling found"
  else
    puts "⚠️  No specific submit button mobile styling"
  end
  
  if css_file.include?('touch-action')
    puts "✅ Touch-action CSS property found"
  else
    puts "⚠️  No touch-action optimization"
  end
rescue => e
  puts "❌ Error checking CSS: #{e.message}"
end

# Check 4: JavaScript
puts "\n4. Checking JavaScript..."
begin
  form_file = File.read('app/views/registrations/new.html.erb')
  
  if form_file.include?('addEventListener')
    puts "✅ JavaScript event listeners found"
  else
    puts "❌ No JavaScript event listeners"
  end
  
  if form_file.include?('touchstart')
    puts "✅ Touch event handling found"
  else
    puts "⚠️  No touch event handling"
  end
  
  if form_file.include?('preventDefault')
    puts "✅ Form prevention logic found"
  else
    puts "⚠️  No form prevention logic"
  end
  
  if form_file.include?('getElementById')
    puts "✅ DOM element targeting found"
  else
    puts "⚠️  Using generic selectors"
  end
rescue => e
  puts "❌ Error checking JavaScript: #{e.message}"
end

# Check 5: Model Validation
puts "\n5. Checking model validations..."
begin
  registration_model = File.read('app/models/registration.rb')
  attendee_model = File.read('app/models/attendee.rb')
  
  if registration_model.include?('validates')
    puts "✅ Registration model has validations"
  else
    puts "⚠️  Registration model might be missing validations"
  end
  
  if attendee_model.include?('validates')
    puts "✅ Attendee model has validations"
  else
    puts "⚠️  Attendee model might be missing validations"
  end
rescue => e
  puts "❌ Error checking models: #{e.message}"
end

puts "\n" + "=" * 50
puts "📱 Mobile-Specific Recommendations:"
puts "1. Test with iPhone Safari, Android Chrome, and older browsers"
puts "2. Check browser developer tools console for JavaScript errors"
puts "3. Verify form fields are properly filled on mobile"
puts "4. Test with mobile network conditions (slower connections)"
puts "5. Check if CSRF tokens are being sent correctly"

puts "\n🧪 To test manually:"
puts "1. Open browser developer tools"
puts "2. Switch to mobile device simulation"
puts "3. Try to submit the form"
puts "4. Check console for any errors"
puts "5. Verify network tab shows form submission"
