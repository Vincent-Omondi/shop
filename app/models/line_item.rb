# app/models/line_item.rb
class LineItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  
  # Add default value for quantity
  before_create :set_default_quantity
  
  def total_price
    product.price * (quantity || 1)  # Fallback to 1 if quantity is nil
  end

  private

  def set_default_quantity
    self.quantity ||= 1
  end
end