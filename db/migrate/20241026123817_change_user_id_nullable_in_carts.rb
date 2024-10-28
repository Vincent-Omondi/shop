class ChangeUserIdNullableInCarts < ActiveRecord::Migration[6.1]
  def change
    # In case the column already exists with NOT NULL constraint
    change_column_null :carts, :user_id, true
  end
end
