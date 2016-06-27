module Stormpath
  module Rails
    module Register
      class CreateController < BaseController
        def call
          form = RegistrationForm.new(
            params.except(:controller, :action, :format, :register, :utf8, :button)
          )
          form.save!

          if form.account.status == 'UNVERIFIED'
            respond_to do |format|
              format.html { redirect_to "#{configuration.web.login.uri}?status=unverified" }
              format.json { render json: AccountSerializer.to_h(form.account) }
            end
          elsif configuration.web.register.auto_login
            AccountLogin.call(cookies, form.email, form.password)
            respond_to do |format|
              format.html { redirect_to configuration.web.register.next_uri }
              format.json { render json: AccountSerializer.to_h(form.account) }
            end
          else
            respond_to do |format|
              format.html { redirect_to "#{configuration.web.login.uri}?status=created" }
              format.json { render json: AccountSerializer.to_h(form.account) }
            end
          end
        rescue RegistrationForm::FormError => error
          reply_with_error(error.message)
        end

        private def reply_with_error(error_message)
          respond_to do |format|
            format.json { render json: { status: 400, message: error_message }, status: 400 }
            format.html do
              set_flash_message :error, error_message
              render template: 'users/new'
            end
          end
        end
      end
    end
  end
end
