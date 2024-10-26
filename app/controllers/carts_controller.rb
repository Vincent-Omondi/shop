# app/controllers/carts_controller.rb
# module CurrentCart
#     private
#       def set_cart
#         @cart = Cart.find_by(id: session[:cart_id])
        
#         if user_signed_in?
#           if @cart && @cart.user_id.nil?
#             # Transfer guest cart to user
#             @cart.update(user: current_user)
#           elsif @cart.nil? || @cart.user_id != current_user.id
#             @cart = Cart.create(user: current_user)
#           end
#         elsif @cart.nil?
#           @cart = Cart.create  # Create cart without user for guests
#         end
        
#         session[:cart_id] = @cart.id
#       end
# end

class CartsController < ApplicationController
  def show
    @cart = Cart.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    logger.error "Attempt to access invalid cart #{params[:id]}"
    redirect_to root_path, notice: 'Invalid cart'
  end

  # Add other actions as needed (index, destroy, etc.)
end