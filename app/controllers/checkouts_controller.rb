class CheckoutsController < ApplicationController
  include CurrentCart
  before_action :set_cart
  before_action :ensure_cart_not_empty

  def new
    @checkout = Checkout.new
  end

  def create
    @checkout = Checkout.new(checkout_params)
    
    if @checkout.valid?
      # Initialize Mpesa payment
      payment = MpesaPayment.create!(
        cart: @cart,
        phone_number: @checkout.phone_number,
        amount: @cart.total_price
      )

      response = initiate_mpesa_payment(payment)
      
      if response[:success]
        redirect_to checkout_confirmation_path(payment), notice: 'Payment initiated. Please check your phone to complete the transaction.'
      else
        redirect_to new_checkout_path, alert: 'Failed to initiate payment. Please try again.'
      end
    else
      render :new
    end
  end

  private

  def checkout_params
    params.require(:checkout).permit(:full_name, :phone_number, :email, :delivery_address)
  end

  def ensure_cart_not_empty
    if @cart.line_items.empty?
      redirect_to root_path, notice: 'Your cart is empty'
    end
  end

  def initiate_mpesa_payment(payment)
    response = MpesaController.new.stkpush(
      phone_number: payment.phone_number,
      amount: payment.amount
    )
    
    if response[0] == :success
      payment.update(
        checkout_request_id: response[1]['CheckoutRequestID'],
        merchant_request_id: response[1]['MerchantRequestID']
      )
      { success: true }
    else
      { success: false }
    end
  end
end 