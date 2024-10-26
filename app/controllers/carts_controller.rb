# app/controllers/carts_controller.rb
class CartsController < ApplicationController
    include CurrentCart
    before_action :set_cart, only: [:show, :destroy]
    
    def show
    end
    
    def destroy
      @cart.destroy if @cart.id == session[:cart_id]
      session[:cart_id] = nil
      
      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Your cart is now empty!' }
        format.json { head :no_content }
      end
    end
  end