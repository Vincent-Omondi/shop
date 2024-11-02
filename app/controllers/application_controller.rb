class ApplicationController < ActionController::Base
  include CurrentCart
  before_action :set_cart
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :devise_controller?
end
