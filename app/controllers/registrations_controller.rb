class RegistrationsController < Devise::RegistrationsController
    private
  
    def sign_up_params
      params.require(:user).permit(permitted_user_attributes)
    end
  
    def account_update_params
      params.require(:user).permit(permitted_user_attributes + [:current_password])
    end
  
    def permitted_user_attributes
      [:name, :email, :password, :password_confirmation]
    end
end