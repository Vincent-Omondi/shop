module ProductsHelper
  def product_author(product)
    user_signed_in? && product.user == current_user
  end

  def seller_name(product)
    product.user ? product.user.name : "Unknown Seller"
  end
end