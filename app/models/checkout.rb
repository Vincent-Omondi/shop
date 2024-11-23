class Checkout
  include ActiveModel::Model
  
  attr_accessor :full_name, :phone_number, :email, :delivery_address
  
  validates :full_name, :phone_number, :email, :delivery_address, presence: true
  validates :phone_number, format: { with: /\A254\d{9}\z/, message: "must be in format 254XXXXXXXXX" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end 