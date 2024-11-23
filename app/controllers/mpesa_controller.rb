class MpesaController < ApplicationController
    protect_from_forgery with: :null_session
  
    # Make stkpush action public
    def stkpush
      phone_number = params[:phoneNumber]
      amount = params[:amount]
      url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      business_short_code = ENV["MPESA_BUSINESS_SHORTCODE"]
      password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")
  
      payload = {
        BusinessShortCode: business_short_code,
        Password: password,
        Timestamp: timestamp,
        TransactionType: "CustomerPayBillOnline",
        Amount: amount,
        PartyA: phone_number,
        PartyB: business_short_code,
        PhoneNumber: phone_number,
        CallBackURL: "#{ENV["CALLBACK_URL"]}/callback_url",
        AccountReference: 'Codearn',
        TransactionDesc: "Payment for Codearn premium"
      }.to_json
  
      headers = {
        Content_type: 'application/json',
        Authorization: "Bearer #{get_access_token}"
      }
  
      response = RestClient::Request.new({
        method: :post,
        url: url,
        payload: payload,
        headers: headers
      }).execute do |response, request|
        case response.code
        when 500
          [:error, JSON.parse(response.to_str)]
        when 400
          [:error, JSON.parse(response.to_str)]
        when 200
          [:success, JSON.parse(response.to_str)]
        else
          fail "Invalid response #{response.to_str} received."
        end
      end
  
      render json: response
    end
  
    def stkquery
      url = "https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query"
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      business_short_code = ENV["MPESA_BUSINESS_SHORTCODE"]
      password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")
  
      payload = {
        BusinessShortCode: business_short_code,
        Password: password,
        Timestamp: timestamp,
        CheckoutRequestID: params[:checkoutRequestID]
      }.to_json
  
      headers = {
        Content_type: 'application/json',
        Authorization: "Bearer #{get_access_token}"
      }
  
      response = RestClient::Request.new({
        method: :post,
        url: url,
        payload: payload,
        headers: headers
      }).execute do |response, request|
        case response.code
        when 500
          [:error, JSON.parse(response.to_str)]
        when 400
          [:error, JSON.parse(response.to_str)]
        when 200
          [:success, JSON.parse(response.to_str)]
        else
          fail "Invalid response #{response.to_str} received."
        end
      end
  
      render json: response
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
      res = generate_access_token_request
      
      if res.code != 200
        r = generate_access_token_request
        raise MpesaError.new('Unable to generate access token') if r.code != 200
        res = r
      end
  
      body = JSON.parse(res, symbolize_names: true)
      token = body[:access_token]
      
      # Only try to save token if AccessToken model exists
      begin
        if defined?(AccessToken)
          AccessToken.destroy_all
          AccessToken.create!(token: token)
        end
      rescue => e
        Rails.logger.error("Failed to save access token: #{e.message}")
      end
      
      token
    end
  end