module Stormpath
  module Rails
    class ApiKey
      TEST_ENV_VARS = {
        required: {
          STORMPATH_CLIENT_APIKEY_ID: 'The id from your Stormpath API Key',
          STORMPATH_CLIENT_APIKEY_SECRET: 'The secret from your Stormpath API Key',
          STORMPATH_APPLICATION_HREF: 'The href to your application'
        },
        deprecated: {
          STORMPATH_API_KEY_ID: 'The id from your Stormpath API Key',
          STORMPATH_API_KEY_SECRET: 'The secret from your Stormpath API Key',
          STORMPATH_APPLICATION_URL: 'The url to your application'
        }
      }.freeze

      def credentials
        check_env_variable_names
        credentials_from_env_variables
      end

      private

      def check_env_variable_names
        unless test_missing_required_env_vars.empty?
          show_deprecation_warning unless env_vars_not_set?
        end

        raise set_up_message if env_vars_not_set?
      end

      def credentials_from_env_variables
        {
          id: ENV['STORMPATH_CLIENT_APIKEY_ID'] || ENV['STORMPATH_API_KEY_ID'],
          secret: ENV['STORMPATH_CLIENT_APIKEY_SECRET'] || ENV['STORMPATH_API_KEY_SECRET']
        }
      end

      def test_missing_deprecated_env_vars
        TEST_ENV_VARS[:deprecated].reject do |var, _|
          ENV[var.to_s]
        end
      end

      def test_missing_required_env_vars
        TEST_ENV_VARS[:required].reject do |var, _|
          ENV[var.to_s]
        end
      end

      def env_vars_not_set?
        !test_missing_deprecated_env_vars.empty? && !test_missing_required_env_vars.empty?
      end

      def show_deprecation_warning
        warn deprecation_warning
      end

      def deprecation_warning
        warn_message = "\n\n"
        40.times { warn_message << '*' }
        warn_message << 'STORMPATH RAILS'
        52.times { warn_message << '*' }
        warn_message << "\n\n"
        warn_message << TEST_ENV_VARS[:deprecated].map do |var, _|
          "\t#{var} is deprecated since the new version of the gem."
        end.join("\n")
        warn_message << "\n\tPlease update your environment variables to use the new names:\n"
        warn_message << "\n\t\texport STORMPATH_CLIENT_APIKEY_ID=your_api_key_id"
        warn_message << "\n\t\texport STORMPATH_CLIENT_APIKEY_SECRET=your_api_key_secret"
        warn_message << "\n\t\texport STORMPATH_APPLICATION_HREF=href_to_application\n\n"
        110.times { warn_message << '*' }
        warn_message << "\n\n"
        warn_message
      end

      def set_up_message
        set_up_message = "In order to use the stormpath-rails gem you need to set the following environment variables:\n\t"
        set_up_message << test_missing_required_env_vars.map do |var, message|
          "#{var} : #{message}"
        end.join("\n\t")
        set_up_message << "\nBe sure to configure these before trying to run your application.\n\n"
        set_up_message
      end
    end
  end
end
