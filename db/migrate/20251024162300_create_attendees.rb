class CreateAttendees < ActiveRecord::Migration[7.2]
  def change
    create_table :attendees do |t|
      t.references :registration, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :dob
      t.string :category

      t.timestamps
    end
  end
end
