# app/models/concerns/current_cart.rb
module CurrentCart
    private
    
    def set_cart
      @cart = Cart.find(session[:cart_id])
    rescue ActiveRecord::RecordNotFound
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
    
    def transfer_cart
      return unless current_user && session[:cart_id]
      
      old_cart = Cart.find_by(id: session[:cart_id])
      user_cart = current_user.cart || current_user.create_cart
      
      if old_cart && old_cart != user_cart
        old_cart.line_items.update_all(cart_id: user_cart.id)
        old_cart.destroy
        session[:cart_id] = user_cart.id
      end
    end
  end