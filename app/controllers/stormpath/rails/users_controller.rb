module Stormpath
  module Rails
    class UsersController < BaseController
      def create
        result = create_stormpath_account(registration_params)

        database_user

        if result.success?
          database_user.save

          if configuration.web.verify_email.enabled
            respond_to do |format|
              format.json { render json: AccountSerializer.to_h(result.account)  }
              format.html { render template: "users/verification_email_sent" }
            end
          else
            initialize_session(database_user, result.account.href)

            respond_to do |format|
              format.json { render json: AccountSerializer.to_h(result.account)  }
              format.html do
                set_flash_message :notice, 'Your account was created successfully'
                redirect_to configuration.web.register.next_uri
              end
            end
          end
        else
          respond_to do |format|
            format.json { render json: { error: result.error_message }, status: 400 }
            format.html do
              set_flash_message :error, result.error_message
              render template: "users/new"
            end
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
            database_user
            respond_to do |format|
              format.json { render json: RegistrationFormSerializer.to_h  }
              format.html { render template: "users/new" }
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
          render template: "users/verification_complete"
        else
          render template: "users/verification_failed"
        end
      end

      private

      def database_user
        @user ||= ::User.new(registration_params.slice(:email, :given_name, :surname))
      end

      def registration_params
        {
          email: params[:email],
          password: params[:password],
          given_name: params[:givenName],
          surname: params[:surname],
          middle_name: params[:middleName],
          username: params[:username]
        }
      end
    end
  end
end
