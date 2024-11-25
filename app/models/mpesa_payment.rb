class MpesaPayment < ApplicationRecord
    belongs_to :cart
    
    enum status: {
      pending: 0,
      completed: 1,
      failed: 2
    }
  
    validates :phone_number, presence: true, 
              format: { with: /\A254\d{9}\z/, message: "must be in format 254XXXXXXXXX" }
    validates :amount, presence: true, numericality: { greater_than: 0 }
end