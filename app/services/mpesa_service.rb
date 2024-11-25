class MpesaService
  def self.initiate_stk_push(phone_number:, amount:)
    new.initiate_stk_push(phone_number: phone_number, amount: amount)
  end

  def initiate_stk_push(phone_number:, amount:)
    begin
      Rails.logger.info("Starting STK Push in MpesaService")
      Rails.logger.info("Phone: #{phone_number}, Amount: #{amount}")

      url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      business_short_code = ENV["MPESA_BUSINESS_SHORTCODE"]
      
      # Format amount to integer
      amount = amount.to_i.to_s
      
      # Format phone number
      phone_number = phone_number.gsub(/^0/, '254')
      phone_number = phone_number.gsub(/^\+/, '')
      
      password = Base64.strict_encode64("#{business_short_code}#{ENV['MPESA_PASSKEY']}#{timestamp}")
      
      # Get access token first
      access_token = get_access_token
      unless access_token
        Rails.logger.error("Failed to get access token")
        return { success: false, error: "Authentication failed" }
      end

      # Get callback URL
      full_callback_url = generate_callback_url
      Rails.logger.info("Using callback URL: #{full_callback_url}")
      
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

      Rails.logger.info("Preparing to send request to Safaricom")
      Rails.logger.info("Payload (masked): #{payload.merge(Password: '[MASKED]').to_json}")

      headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer #{access_token}"
      }

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
        { success: true, data: parsed_response }
      else
        Rails.logger.error("Failed: #{response.body}")
        { success: false, error: parsed_response["errorMessage"] || "Payment initiation failed" }
      end
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error("REST Client Error: #{e.message}")
      Rails.logger.error("Response Body: #{e.response&.body}")
      error_message = begin
        JSON.parse(e.response&.body)["errorMessage"] rescue e.message
      end
      { success: false, error: "Service communication error: #{error_message}" }
    rescue StandardError => e
      Rails.logger.error("STK Push error: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { success: false, error: "System error occurred: #{e.message}" }
    end
  end

  private

  def get_access_token
    begin
      url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
      consumer_key = ENV["MPESA_CONSUMER_KEY"]
      consumer_secret = ENV["MPESA_CONSUMER_SECRET"]
      
      unless consumer_key && consumer_secret
        Rails.logger.error("Missing MPESA_CONSUMER_KEY or MPESA_CONSUMER_SECRET")
        return nil
      end
      
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

  def generate_callback_url
    base_url = ENV['APP_BASE_URL']
    
    unless base_url
      Rails.logger.warn("APP_BASE_URL not set, attempting to use default callback URL")
      # Match the callback URL path from your routes.rb
      return "#{request_base_url}/mpesa/callback"
    end
    
    "#{base_url.chomp('/')}/mpesa/callback"
  end

  def request_base_url
    if Rails.env.development?
      "http://localhost:3000"
    else
      Rails.application.routes.default_url_options[:host] || "https://your-production-domain.com"
    end
  end
end 