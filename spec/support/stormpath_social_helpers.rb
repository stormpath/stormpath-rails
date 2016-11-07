module Stormpath
  module Social
    module Helpers
      def self.mocked_account(provider)
        if provider.to_sym == :google
          MultiJson.dump(GOOGLE_ACCOUNT)
        elsif provider.to_sym == :facebook
          MultiJson.dump(FACEBOOK_ACCOUNT)
        elsif provider.to_sym == :linkedin
          MultiJson.dump(LINKEDIN_ACCOUNT)
        elsif provider.to_sym == :github
          MultiJson.dump(GITHUB_ACCOUNT)
        end
      end

      def self.mocked_authorization_code_for(provider)
        if provider.to_sym == :facebook
          MultiJson.dump(FACEBOOK_AUTH_CODE)
        elsif provider.to_sym == :github
          MultiJson.dump(GITHUB_AUTH_CODE)
        end
      end

      def self.mocked_access_token_for(provider)
        if provider.to_sym == :google
          MultiJson.dump(GOOGLE_ACCESS_TOKEN)
        elsif provider.to_sym == :facebook
          MultiJson.dump(FACEBOOK_ACCESS_TOKEN)
        elsif provider.to_sym == :linkedin
          MultiJson.dump(LINKEDIN_ACCESS_TOKEN)
        elsif provider.to_sym == :github
          MultiJson.dump(GITHUB_ACCESS_TOKEN)
        end
      end

      def self.access_denied_response
        MultiJson.dump(ACCESS_DENIED_RESPONSE)
      end

      def self.code_mismatch
        MultiJson.dump(ERROR_CODE_RESPONSE)
      end

      FACEBOOK_AUTH_CODE = {
        code: 'AQD6re9dXou1C32Mix81qQ19n_nKNn6tuY8ZytoQ01BhV8_ejI-78JRofwrU-DKsNRQPw_6H26k_Eryz6WWGEEGjfSNIs84I5KF6Uwn4HOfx17gaGjbOxq8_Q4gpuAhYk93aNS5dR1OR8VDPMfIig_ZOP56kBsr-1SRJncCJLmKqhjOVdZwukoQ8ZnpK18V8p07nZqgf12lZVUu-qvhllUi2UnayTdgL3I66oBDgPgFML3u1uJ0STuQYWQuLiDpTcjGuhAJTHIne_z0dpdWjNg1hjiCn13WxOPTPGKf0F-9p0LDlsSiNH8CZwyrWCUa2x8JzjomW4wdQ2S3tboS6APGV'
      }.freeze

      GITHUB_AUTH_CODE = {
        code: '734dfb156ffa2c347487'
      }.freeze

      FACEBOOK_ACCESS_TOKEN = {
        'access_token' => 'EAAPyFJXxH5sBAAoMxK4MeVqyP6JLV9ZBX66ETvUtz78ZCAtZAGw2ZCUY3ZA6MO25ncDU595yHzqRlOHZBN3RECK3vgMSVDRbZCZC5R01FLS3euPtiWwqD4H9cIrqflryUe42XiV0wB3qPMm7WDLkFGvDJ1y8un75EnUZD',
        'token_type' => 'bearer',
        'expires_in' => 5108154
      }.freeze

      GOOGLE_ACCESS_TOKEN = {
        'code' => '4/okLRF-ggM6QPFaD6uJlhNdR0AVVXx9FooEoS9vSrpyE'
      }.freeze

      GITHUB_ACCESS_TOKEN = {
        'access_token' => 'aa2fb9c59c9d9b6ae1e7559cfa88d1c6ab6e4eef',
        'token_type' => 'bearer',
        'scope' => 'user:email'
      }.freeze

      LINKEDIN_ACCESS_TOKEN = {
        'code' => 'AQRrgr5mM_P2dUStbkKYWRhqao5wia8Ol8NHN84z1t3RF5yEbb1X-WCGjOt6UPfNkszBvmEwGWUsidhEPoi0c4MCzR32Fdbvfxf7e9XJR6hzYWjsAWk',
      }.freeze

      ACCESS_DENIED_RESPONSE = {
        'error' => 'access_denied',
        'error_code' => '200',
        'error_description' => 'Permissions error',
        'error_reason' => 'user_denied',
        'controller' => 'stormpath/rails/social/facebook',
        'action' => 'create',
        'format' => 'html'
      }.freeze

      ERROR_CODE_RESPONSE = {
        'error' => {
          'message' => 'Invalid verification code format.',
          'type' => 'OAuthException',
          'code' => 100
        }
      }.freeze

      GOOGLE_ACCOUNT = {
        href: 'https://api.stormpath.com/v1/accounts/4MgSZmUZBJP5nGSkrfMgyl',
        username: 'os.chilim@gmail.com',
        email: 'os.chilim@gmail.com',
        givenName: "Marko",
        middleName: nil,
        surname: 'Ćilimković',
        fullName: "Marko Ćilimković",
        status: "ENABLED",
        emailVerificationToken: nil,
        customData: { href: "https://api.stormpath.com/v1/accounts/6bC2rHOzrqf2s8CIegki35/customData" },
        providerData: { href: "https://api.stormpath.com/v1/accounts/6bC2rHOzrqf2s8CIegki35/providerData" },
        directory: { href: "https://api.stormpath.com/v1/directories/2WU9sRpSn5jpVADlQTAltT" },
        tenant: { href: "https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk" },
        groups: { href: "https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/groups" },
        groupMemberships: { href: "https://api.stormpath.com/v1/accounts/2XdHmcyFG8HJCYBTEL1dJj/groupMemberships" }
      }

      FACEBOOK_ACCOUNT = {
        href: 'https://api.stormpath.com/v1/accounts/6bC2rHOzrqf2s8CIegki35',
        username: 'os.chilim@gmail.com',
        email: 'os.chilim@gmail.com',
        givenName: "Marko",
        middleName: nil,
        surname: 'Ćilimković',
        fullName: "Marko Ćilimković",
        status: "ENABLED",
        emailVerificationToken: nil,
        customData: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/customData"},
        providerData: { href:"https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData"},
        directory: { href: "https://api.stormpath.com/v1/directories/7ibyn2idP1d9p3qJOomeNP"},
        tenant: { href: "https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk"},
        groups: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groups"},
        groupMemberships: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groupMemberships"}
      }

      LINKEDIN_ACCOUNT = {
        href: 'https://api.stormpath.com/v1/accounts/6xX1g9CeKEPJDfdNtId1ya',
        username: 'os.chilim@gmail.com',
        email: 'os.chilim@gmail.com',
        givenName: "Marko",
        middleName: nil,
        surname: 'Ćilimković',
        fullName: "Marko Ćilimković",
        status: "ENABLED",
        emailVerificationToken: nil,
        customData: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/customData"},
        providerData: { href:"https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData"},
        directory: { href: "https://api.stormpath.com/v1/directories/7ibyn2idP1d9p3qJOomeNP"},
        tenant: { href: "https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk"},
        groups: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groups"},
        groupMemberships: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groupMemberships"}
      }

      GITHUB_ACCOUNT = {
        href: 'https://api.stormpath.com/v1/accounts/4WRsCD7wtWZgWnSKhqJZYZ',
        username: 'cilim',
        email: 'marko.cilimkovic@infinum.hr',
        givenName: "Marko",
        middleName: nil,
        surname: 'Ćilimković',
        fullName: "Marko Ćilimković",
        status: "ENABLED",
        emailVerificationToken: nil,
        customData: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/customData"},
        providerData: { href:"https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/providerData"},
        directory: { href: "https://api.stormpath.com/v1/directories/7ibyn2idP1d9p3qJOomeNP"},
        tenant: { href: "https://api.stormpath.com/v1/tenants/60bD3bKLej6JoFhyKFHiOk"},
        groups: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groups"},
        groupMemberships: { href: "https://api.stormpath.com/v1/accounts/7jdiPam0PWES317hwRR5a7/groupMemberships"}
      }
    end
  end
end
