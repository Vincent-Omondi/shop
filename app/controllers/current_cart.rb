# app/controllers/concerns/current_cart.rb
module CurrentCart
  private
    def set_cart
      @cart = Cart.find_by(id: session[:cart_id])
      
      if user_signed_in?
        if @cart && @cart.user_id.nil?
          # Transfer guest cart to user
          @cart.update(user_id: current_user.id)
        elsif @cart.nil? || @cart.user_id != current_user.id
          @cart = Cart.create(user_id: current_user.id)
        end
      elsif @cart.nil?
        @cart = Cart.create  # Create cart without user for guests
      end
      
      session[:cart_id] = @cart.id
    end
end