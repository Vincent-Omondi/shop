class MpesaController < ApplicationController
    protect_from_forgery with: :null_session
  
    # Make stkpush action public
    def stkpush
      # Extract parameters from the request
      phone_number = params.dig(:mpesa, :phoneNumber) || params[:phoneNumber]
      amount = params.dig(:mpesa, :amount) || params[:amount]

      begin
        Rails.logger.info("Starting STK Push request")
        Rails.logger.info("Phone: #{phone_number}, Amount: #{amount}")
        
        # Validate inputs
        unless phone_number.present? && amount.present?
          Rails.logger.error("Missing required parameters")
          return render json: { error: "Missing required parameters" }, status: :unprocessable_entity
        end

        # Get the callback URL from environment variable or use the ngrok URL
        callback_url = ENV['APP_BASE_URL'] || request.base_url
        Rails.logger.info("Base URL: #{callback_url}")
        
        # Format callback URL
        callback_url = callback_url.chomp('/')  # Remove trailing slash if present
        full_callback_url = "#{callback_url}/api/v1/mpesa_callback"
        Rails.logger.info("Full callback URL: #{full_callback_url}")
        
        url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
        timestamp = Time.now.strftime("%Y%m%d%H%M%S")
        business_short_code = ENV["MPESA_BUSINESS_SHORTCODE"]
        
        # Format amount to integer (M-Pesa doesn't accept decimals)
        amount = amount.to_i.to_s
        
        # Format phone number (remove leading zero if present)
        phone_number = phone_number.gsub(/^0/, '254')
        phone_number = phone_number.gsub(/^\+/, '')
        
        password = Base64.strict_encode64("#{business_short_code}#{ENV['MPESA_PASSKEY']}#{timestamp}")
        
        payload = {
          BusinessShortCode: business_short_code,
          Password: password,
          Timestamp: timestamp,
          TransactionType: "CustomerPayBillOnline",
          Amount: amount,
          PartyA: phone_number,
          PartyB: business_short_code,
          PhoneNumber: phone_number,
          CallBackURL: full_callback_url,
          AccountReference: "Shop Payment",
          TransactionDesc: "Payment for shop items"
        }

        Rails.logger.info("Callback URL: #{payload[:CallBackURL]}")
        
        Rails.logger.info("Preparing to send request to Safaricom")
        Rails.logger.info("Payload (masked): #{payload.merge(Password: '[MASKED]').to_json}")

        access_token = get_access_token
        unless access_token
          Rails.logger.error("Failed to get access token")
          return render json: { error: "Authentication failed" }, status: :unauthorized
        end

        headers = {
          'Content-Type': 'application/json',
          'Authorization': "Bearer #{access_token}"
        }

        Rails.logger.info("Sending request to Safaricom...")
        
        # Log the full request details (for debugging)
        Rails.logger.debug("Request URL: #{url}")
        Rails.logger.debug("Request Headers: #{headers.inspect}")
        Rails.logger.debug("Request Payload: #{payload.to_json}")
        
        response = RestClient::Request.execute(
          method: :post,
          url: url,
          payload: payload.to_json,
          headers: headers,
          verify_ssl: false
        )
        
        Rails.logger.info("Response received: #{response.body}")
        parsed_response = JSON.parse(response.body)
        
        if parsed_response["ResponseCode"] == "0"
          Rails.logger.info("Success: #{response.body}")
          render json: { success: true, data: parsed_response }, status: :ok
        else
          Rails.logger.error("Failed: #{response.body}")
          render json: { error: parsed_response["errorMessage"] || "Payment initiation failed" }, status: :unprocessable_entity
        end

      rescue RestClient::ExceptionWithResponse => e
        Rails.logger.error("REST Client Error: #{e.message}")
        Rails.logger.error("Response Body: #{e.response&.body}")
        
        # Parse the error response if possible
        error_message = begin
          JSON.parse(e.response&.body)["errorMessage"] rescue e.message
        end
        
        render json: { error: "Service communication error: #{error_message}" }, status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error("Unexpected error in stkpush: #{e.class} - #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
      end
    end
  
    def stkquery
      checkout_request_id = params[:CheckoutRequestID]
      
      unless checkout_request_id.present?
        return render json: { success: false, error: "CheckoutRequestID is required" }, 
                     status: :unprocessable_entity
      end

      begin
        url = "https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query"
        timestamp = Time.now.strftime("%Y%m%d%H%M%S")
        business_short_code = ENV["MPESA_BUSINESS_SHORTCODE"]
        password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")

        payload = {
          BusinessShortCode: business_short_code,
          Password: password,
          Timestamp: timestamp,
          CheckoutRequestID: checkout_request_id
        }.to_json

        headers = {
          'Content-Type': 'application/json',
          'Authorization': "Bearer #{get_access_token}"
        }

        response = RestClient.post(url, payload, headers)
        
        case response.code
        when 200
          result = JSON.parse(response.body)
          render json: { success: true, data: result }, status: :ok
        else
          render json: { success: false, error: "Unexpected response: #{response.code}" }, 
                 status: :unprocessable_entity
        end

      rescue RestClient::ExceptionWithResponse => e
        error_response = JSON.parse(e.response.body) rescue { error: e.message }
        Rails.logger.error("STK Query failed: #{error_response}")
        render json: { success: false, error: error_response }, 
               status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error("STK Query error: #{e.message}")
        render json: { success: false, error: "Internal server error" }, 
               status: :internal_server_error
      end
    end
  
    def callback
      # Log the callback response
      Rails.logger.info "M-PESA CALLBACK: #{params.inspect}"
      
      # Process the callback
      render json: { 
        ResultCode: 0,
        ResultDesc: "Success"
      }
    end
  
    private
  
    def generate_access_token_request
      url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
      consumer_key = ENV['MPESA_CONSUMER_KEY']
      consumer_secret = ENV['MPESA_CONSUMER_SECRET']
      userpass = Base64::strict_encode64("#{consumer_key}:#{consumer_secret}")
  
      RestClient::Request.execute(
        url: url,
        method: :get,
        headers: {
          Authorization: "Basic #{userpass}"
        }
      )
    end
  
    def get_access_token
      begin
        url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
        consumer_key = ENV["MPESA_CONSUMER_KEY"]
        consumer_secret = ENV["MPESA_CONSUMER_SECRET"]
        
        auth = Base64.strict_encode64("#{consumer_key}:#{consumer_secret}")
        headers = {
          'Authorization': "Basic #{auth}"
        }

        response = RestClient.get(url, headers)
        JSON.parse(response.body)["access_token"]
      rescue => e
        Rails.logger.error("Access token error: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        nil
      end
    end
end