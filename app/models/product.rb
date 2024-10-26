class Product < ApplicationRecord
  before_destroy :not_referenced_by_any_line_item
  belongs_to :user  # Remove optional: true to ensure every product has a user
  mount_uploader :image, ImageUploader
  serialize :image, JSON # If you use SQLite, add this line

  validates :title, :brand, :price, :model, presence: true
  validates :description, length: { maximum: 1000, too_long: "%{count} characters is the maximum allowed." }  # Fixed typo in "allowed"
  validates :title, length: { maximum: 140, too_long: "%{count} characters is the maximum allowed." }  # Fixed typo in "allowed"
  validates :price, length: { maximum: 10 }
  validates :user_id, presence: true  # Add this line

  BRAND = %w{ Ferrari Opel Lenovo Fossil }
  FINISH = %w{ Black White Navy Blue Red Clear Satin Yellow Seafoam }
  CONDITION = %w{ New Excellent Mint Used Fair Poor }

  private

  def not_referenced_by_any_line_item
    unless line_items.empty?
      errors.add(:base, "Line items present")
      throw :abort
    end
  end
end