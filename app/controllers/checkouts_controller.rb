class CheckoutsController < ApplicationController
  include CurrentCart
  before_action :set_cart
  before_action :ensure_cart_not_empty, except: [:confirmation]

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
          redirect_to confirmation_checkout_path(payment),
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

  def confirmation
    @payment = MpesaPayment.find(params[:id])
    # You can add any additional logic needed for the confirmation page
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Payment not found'
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
    Rails.logger.info("Initiating M-Pesa payment for payment ID: #{payment.id}")
    Rails.logger.info("Phone number: #{payment.phone_number}, Amount: #{payment.amount}")

    response = MpesaService.initiate_stk_push(
      phone_number: payment.phone_number,
      amount: payment.amount
    )

    if response[:success]
      begin
        payment.update!(
          checkout_request_id: response[:data]['CheckoutRequestID'],
          merchant_request_id: response[:data]['MerchantRequestID'],
          status: 'pending'
        )
        { success: true, message: 'Payment initiated successfully' }
      rescue => e
        Rails.logger.error("Failed to update payment record: #{e.message}")
        { success: false, message: "Failed to save payment details: #{e.message}" }
      end
    else
      Rails.logger.error("Mpesa payment failed: #{response.inspect}")
      { success: false, message: response[:error] }
    end
  rescue => e
    Rails.logger.error("Payment initiation error: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    { success: false, message: "System error occurred: #{e.message}" }
  end
end 