class CreateEventRegistrations < ActiveRecord::Migration[7.2]
  def change
    create_table :event_registrations do |t|
      t.references :association_event, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :total_cents
      t.string :currency
      t.string :status
      t.string :stripe_checkout_session_id
      t.string :stripe_payment_intent_id
      t.datetime :paid_at

      t.timestamps
    end
  end
end
