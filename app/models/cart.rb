# app/models/cart.rb
class Cart < ApplicationRecord
    has_many :line_items, dependent: :destroy
    
    def add_product(product)
      current_item = line_items.find_by(product_id: product.id)
      
      if current_item
        current_item.increment(:quantity)
      else
        current_item = line_items.build(product_id: product.id)
      end
      current_item
    end
    
    def total_price
      line_items.sum { |item| item.total_price }
    end
    
    def total_items
      line_items.sum(:quantity)
    end
  end
  
  # app/models/line_item.rb
  class LineItem < ApplicationRecord
    belongs_to :cart
    belongs_to :product
    
    def total_price
      product.price * quantity
    end
  end