# app/controllers/line_items_controller.rb
# class LineItemsController < ApplicationController
#     include CurrentCart
#     before_action :set_cart, only: [:create]
#     before_action :set_line_item, only: [:destroy]
    
#     def create
#       product = Product.find(params[:product_id])
#       @line_item = @cart.add_product(product)
      
#       respond_to do |format|
#         if @line_item.save
#           format.html { redirect_back(fallback_location: root_path, notice: 'Added to your cart') }
#           format.js   { @current_item = @line_item }
#           format.json { render :show, status: :created, location: @line_item }
#         else
#           format.html { render :new }
#           format.json { render json: @line_item.errors, status: :unprocessable_entity }
#         end
#       end
#     end
    
#     def destroy
#       @cart = Cart.find(session[:cart_id])
#       @line_item.destroy
      
#       respond_to do |format|
#         format.html { redirect_to cart_path(@cart), notice: 'Removed from your cart' }
#         format.json { head :no_content }
#       end
#     end
    
#     private
#       def set_line_item
#         @line_item = LineItem.find(params[:id])
#       end
#   end

class LineItemsController < ApplicationController
  include CurrentCart
  before_action :set_cart, only: [:create, :destroy]

  def create
    product = Product.find(params[:product_id])
    @line_item = @cart.add_product(product)

    if @line_item.save
      redirect_to @line_item.cart, notice: 'Item added to your cart'
    else
      redirect_to product, alert: 'Failed to add item to cart'
    end
  end

  def destroy
    @line_item = LineItem.find(params[:id])
    @line_item.destroy
    redirect_to @cart, notice: 'Item removed from your cart'
  end
end