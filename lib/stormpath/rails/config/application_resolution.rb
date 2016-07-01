module Stormpath
  module Rails
    module Config
      class ApplicationResolution
        attr_reader :href, :name

        AUTOMATIC_RESOLUTION_ERROR_MESSAGE =
          'Could not automatically resolve a Stormpath Application. '\
          'Please specify your Stormpath Application in your configuration.'.freeze

        def initialize(href, name)
          @href = href
          @name = name
        end

        def app
          if href.present?
            app_from_href
          elsif name.present?
            app_from_name
          else
            automatic_resolution
          end
        end

        private

        def automatic_resolution
          if client_has_exactly_two_applications?
            client_applications.find { |app| app.name != 'Stormpath' }
          else
            raise(InvalidConfiguration, AUTOMATIC_RESOLUTION_ERROR_MESSAGE)
          end
        end

        def client_has_exactly_two_applications?
          client_applications.count == 2
        end

        def client_applications
          @client_applications ||= Stormpath::Rails::Client.client.applications
        end

        def app_from_href
          verify_application_href
          begin
            Stormpath::Rails::Client.client.applications.get(href)
          rescue Stormpath::Error => error
            raise if error.status != 404
            raise(
              InvalidConfiguration,
              "The provided application could not be found. The provided application href was: #{href}"
            )
          end
        end

        def verify_application_href
          if href && href !~ /applications/
            raise(
              InvalidConfiguration,
              "#{href} is not a valid Stormpath Application href."
            )
          end
        end

        def app_from_name
          application = Stormpath::Rails::Client.client.applications.search(name: name).first
          application || raise(
            InvalidConfiguration,
            "The provided application could not be found. The provided application name was: #{name}"
          )
        end
      end
    end
  end
end
