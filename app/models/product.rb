class Product < ApplicationRecord
  before_destroy :not_referenced_by_any_line_item
  belongs_to :user
  mount_uploader :image, ImageUploader
  has_many :line_items, dependent: :restrict_with_error
  serialize :image, JSON # For SQLite

  BRAND = %w{ Ferrari Opel Lenovo Fossil }
  FINISH = %w{ Black White Navy Blue Red Clear Satin Yellow Seafoam }
  CONDITION = %w{ New Excellent Mint Used Fair Poor }

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true, length: { maximum: 1000, too_long: "%{count} characters is the maximum allowed." }
  validates :brand, presence: true
  validates :finish, presence: true
  validates :condition, presence: true
  validates :image, presence: true
  validates :user_id, presence: true
  validates :title, length: { maximum: 140, too_long: "%{count} characters is the maximum allowed." }
  validates :price, length: { maximum: 10 }

  private

  def not_referenced_by_any_line_item
    if line_items.any?
      errors.add(:base, "Cannot delete product while it's in a cart")
      throw :abort
    end
  end

  def all_fields_present
    required_fields = [brand, description, condition, finish, title, price, image]
    if required_fields.any?(&:blank?)
      errors.add(:base, "Please fill in all required fields and attach an image")
    end
  end
end