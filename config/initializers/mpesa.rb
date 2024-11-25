MPESA_CONFIG = {
  consumer_key: ENV['MPESA_CONSUMER_KEY'],
  consumer_secret: ENV['MPESA_CONSUMER_SECRET'],
  passkey: ENV['MPESA_PASSKEY'],
  shortcode: ENV['MPESA_BUSINESS_SHORTCODE'],
  environment: ENV['MPESA_ENVIRONMENT'] || 'sandbox'
}