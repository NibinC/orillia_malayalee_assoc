# Admin User Management

Since admin registration is disabled for security purposes, admin users must be created through one of the following methods:

## Method 1: Database Seeds
Run the seeds file to create the default admin user:
```bash
rails db:seed
```

Default admin credentials:
- Email: admin@oma.ca
- Password: ChangeMe123!

## Method 2: Rails Console
Create additional admin users via Rails console:
```bash
rails console
```

Then run:
```ruby
AdminUser.create!(
  email: "new_admin@oma.ca",
  password: "SecurePassword123!",
  password_confirmation: "SecurePassword123!"
)
```

## Method 3: Update Seeds File
Add new admin users to `db/seeds.rb` and run `rails db:seed`

## Security Notes
- Always change default passwords in production
- Use strong passwords for admin accounts
- Consider implementing additional authentication measures for production
