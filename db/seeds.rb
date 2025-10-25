# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Event.create!(
  name: "Onam 2025 – Orillia Malayalee Association",
  description: "Cultural program, Sadya, and community gathering.",
  starts_at: Time.zone.parse("2025-09-14 12:00"),
  adult_price_cents: 2500,  # $25.00
  minor_price_cents: 1200,  # $12.00
  currency: "CAD",
  published: true
)

# Create default admin user (since registration is disabled)
# To create additional admin users, add them here or use Rails console
AdminUser.find_or_create_by!(email: "admin@oma.ca") do |admin|
  admin.password = "ChangeMe123!"
  admin.password_confirmation = "ChangeMe123!"
end
