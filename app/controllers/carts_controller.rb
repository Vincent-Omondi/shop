# app/controllers/carts_controller.rb
class CartsController < ApplicationController
  include CurrentCart
  before_action :set_cart, only: [:show, :destroy, :empty]

  def show
    @cart = Cart.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    logger.error "Attempt to access invalid cart #{params[:id]}"
    redirect_to root_path, notice: 'Invalid cart'
  end

  def destroy
    @cart.destroy if @cart.id == session[:cart_id]
    session[:cart_id] = nil
    redirect_to root_path, notice: 'Your cart is currently empty'
  end

  def empty
    @cart.line_items.destroy_all
    redirect_to @cart, notice: 'Cart emptied successfully'
  end

end