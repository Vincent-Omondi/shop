class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.references :user, foreign_key: true, null: true  # Explicitly set null: true

      t.timestamps
    end
  end
end