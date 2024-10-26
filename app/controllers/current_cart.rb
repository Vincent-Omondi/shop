# app/controllers/concerns/current_cart.rb
# module CurrentCart
#     private
#       def set_cart
#         @cart = Cart.find(session[:cart_id])
#       rescue ActiveRecord::RecordNotFound
#         @cart = Cart.create
#         session[:cart_id] = @cart.id
#       end
#   end

module CurrentCart
  private
    def set_cart
      @cart = Cart.find_by(id: session[:cart_id])
      
      if user_signed_in?
        if @cart && @cart.user_id.nil?
          # Transfer guest cart to user
          @cart.update(user: current_user)
        elsif @cart.nil? || @cart.user_id != current_user.id
          @cart = Cart.create(user: current_user)
        end
      elsif @cart.nil?
        @cart = Cart.create  # Create cart without user for guests
      end
      
      session[:cart_id] = @cart.id
    end
end