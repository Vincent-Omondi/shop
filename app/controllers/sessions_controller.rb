# app/controllers/sessions_controller.rb
class SessionsController < Devise::SessionsController
    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    rescue => e
      respond_to do |format|
        format.html { redirect_to new_user_session_path, alert: "Invalid email or password" }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("login_form", partial: "devise/sessions/form", locals: { alert: "Invalid email or password" })
        end
      end
    end
  end