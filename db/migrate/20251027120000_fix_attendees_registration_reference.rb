# Fix mismatched foreign key/column for attendees (no-op if already correct)
class FixAttendeesRegistrationReference < ActiveRecord::Migration[7.2]
  def up
    # Ensure column name is registration_id
    if column_exists?(:attendees, :event_registration_id) && !column_exists?(:attendees, :registration_id)
      rename_column :attendees, :event_registration_id, :registration_id
    end

    # Ensure FK points to registrations
    if foreign_key_exists?(:attendees, :event_registrations)
      remove_foreign_key :attendees, :event_registrations
    end
    add_foreign_key :attendees, :registrations unless foreign_key_exists?(:attendees, :registrations)
    add_index :attendees, :registration_id unless index_exists?(:attendees, :registration_id)
    change_column_null :attendees, :registration_id, false if column_exists?(:attendees, :registration_id)
  end

  def down
    # Best effort rollback (do nothing destructive)
  end
end
