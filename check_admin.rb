puts "Admin Users Count: #{AdminUser.count}"
if AdminUser.exists?
  puts "First Admin User: #{AdminUser.first.email}"
else
  puts "No admin users found. Creating one..."
  admin = AdminUser.create!(
    email: 'admin@orma.org',
    password: 'password123',
    password_confirmation: 'password123'
  )
  puts "Created admin user: #{admin.email}"
end
