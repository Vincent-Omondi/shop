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
      begin
        Rails.logger.info("Creating payment for checkout: #{checkout_params.inspect}")
        
        payment = MpesaPayment.create!(
          cart: @cart,
          phone_number: @checkout.phone_number,
          amount: @cart.total_price
        )
        
        response = initiate_mpesa_payment(payment)
        
        if response[:success]
          redirect_to checkout_confirmation_path(payment),
                      notice: 'Payment initiated. Please check your phone to complete the transaction.'
        else
          error_message = response[:message] || 'Failed to initiate payment'
          Rails.logger.error("Payment initiation failed: #{error_message}")
          redirect_to new_checkout_path,
                      alert: "Payment failed: #{error_message}"
        end
      rescue => e
        Rails.logger.error("Checkout error: #{e.class} - #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        redirect_to new_checkout_path,
                    alert: "Payment failed: #{e.message}"
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
    
    case response[0]
    when :success
      payment.update!(
        checkout_request_id: response[1]['CheckoutRequestID'],
        merchant_request_id: response[1]['MerchantRequestID'],
        status: 'pending'
      )
      { success: true, message: 'Payment initiated successfully' }
    when :error
      Rails.logger.error("Mpesa payment failed: #{response[1]}")
      { success: false, message: response[1] || 'Payment initiation failed' }
    else
      Rails.logger.error("Unexpected response from Mpesa: #{response.inspect}")
      { success: false, message: 'Unexpected error occurred' }
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to update payment record: #{e.message}")
    { success: false, message: 'Failed to save payment details' }
  rescue StandardError => e
    Rails.logger.error("Mpesa payment initiation failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    { success: false, message: 'System error occurred' }
  end
end 