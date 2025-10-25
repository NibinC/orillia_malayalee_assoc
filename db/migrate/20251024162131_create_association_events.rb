class CreateAssociationEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :association_events do |t|
      t.string :name
      t.text :description
      t.datetime :starts_at
      t.integer :adult_price_cents
      t.integer :minor_price_cents
      t.string :currency
      t.boolean :published

      t.timestamps
    end
  end
end
