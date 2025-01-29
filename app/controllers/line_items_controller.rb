# app/controllers/line_items_controller.rb
class LineItemsController < ApplicationController
  include CurrentCart
  before_action :set_cart
  before_action :set_line_item, only: [:destroy, :update_quantity]

  def create
    product = Product.find(params[:product_id])
    @line_item = @cart.add_product(product)

    if @line_item.save
      redirect_back(fallback_location: root_path, notice: "Added to your cart")  # <- Changed this line
    else
      redirect_to product, alert: "Failed to add to cart"
    end
  end

  def destroy
    product_title = @line_item.product.title
    @line_item.destroy
    redirect_to @cart, notice: "Removed from your cart"
  end

  def update_quantity
    product_title = @line_item.product.title
    if params[:change] == 'increase'
      @line_item.quantity += 1
    elsif params[:change] == 'decrease' && @line_item.quantity > 1
      @line_item.quantity -= 1
    end

    if @line_item.save
      redirect_to @cart, notice: "#{product_title} quantity updated"
    else
      redirect_to @cart, alert: "Error updating #{product_title} quantity"
    end
  end

  private

  def set_line_item
    @line_item = LineItem.find(params[:id])
  end
end
