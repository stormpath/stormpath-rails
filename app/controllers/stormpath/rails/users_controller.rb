module Stormpath
  module Rails
    class UsersController < BaseController
      def create
        form = RegistrationForm.new(
          params.except(:controller, :action, :format, :user, :utf8, :button)
        )
        form.save!

        if configuration.web.verify_email.enabled
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

      def new
        if configuration.web.id_site.enabled
          redirect_to id_site_register_url
        else
          if signed_in?
            redirect_to root_path
          else
            respond_to do |format|
              format.json { render json: RegistrationFormSerializer.to_h }
              format.html { render template: 'users/new' }
            end
          end
        end
      end

      def profile
        if signed_in?
          account = get_account current_user_href
          render json: account.properties
        else
          render nothing: true, status: 401
        end
      end

      def verify
        result = verify_email_token params[:sptoken]

        if result.success?
          @account_url = result.account_url
          render template: 'users/verification_complete'
        else
          render template: 'users/verification_failed'
        end
      end
    end
  end
end
