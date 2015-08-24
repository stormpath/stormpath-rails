# Stormpath::Rails.configure do |config|
#   config.api_key_file = ENV['STORMPATH_API_KEY_FILE_LOCATION']
#   config.application = ENV['STORMPATH_SDK_TEST_APPLICATION_URL']
# end

Stormpath::Rails.configure ({
  client: {
    api_key:{
      file: ENV['STORMPATH_API_KEY_FILE_LOCATION'],
      id:"",
      secret:""
    },
    cache_manager:{
      default_ttl: 300,
      default_tti: 300,
      caches: {
        account: {
          ttl: 300,
          tti: 300
        }
      }
    },
    base_url: "https://api.stormpath.com/v1",
    connection_timeout: 30,
    authentication_scheme: "SAUTHC1",
    proxy:{
      port: "",
      host: "",
      username: "",
      password: ""
    }
  },
  application: {
    name: "test",
    href: ENV['STORMPATH_SDK_TEST_APPLICATION_URL']
  },
  web: {
    oauth2:{
      enabled: false,
      uri: "/oauth/token",
      client_credentials:{
        enabled: true,
        accessToken:{
          ttl: 3600
        }
      }
    },
    accessTokenCookie:{
      name: "access_token",
      httpOnly: true,
      secure: nil,
      path: "/",
      domain: nil
    },
    register: {
      enabled: false,
      uri: "/register",
      nextUri: "/",
      autoAuthorize: false,
      fields: {
        givenName: {
          name: "givenName",
          placeholder: "First Name",
          required: true,
          type: "text"
        },
        middleName: {
          name: "middleName",
          placeholder: "Middle Name",
          required: false,
          type: "text"
        },
        surname: {
          name: "surname",
          placeholder: "Last Name",
          required: true,
          type: "text"
        },
        email: {
          name: "email",
          placeholder: "Email",
          required: true,
          type: "email"
        },
        password: {
          name: "password",
          placeholder: "Password",
          required: true,
          type: "password"
        },
        passwordConfirm: {
          name: "passwordConfirm",
          placeholder: "Confirm Password",
          required: false,
          type: "password"
        }
      },
      fieldOrder: [ "givenName", "middleName", "surname", "email", "password", "passwordConfirm" ],
      view: "register"
    },
    verifyEmail: {
      enabled: true,
      uri: "/verify",
      nextUri: "/",
      view: "verify"
    },
    login: {
      enabled: false,
      autoLogin: true,
      uri: "/login",
      nextUri: "/",
      view: "login"
    },
    logout: {
      enabled: false,
      uri: "/logout",
      nextUri: "/"
    },
    forgotPassword: {
      enabled: false,
      uri: "/forgot",
      view: "forgot-password",
      nextUri: "/login?status=forgot"
    },
    changePassword: {
      enabled: false,
      autoLogin: false,
      uri: "/change",
      nextUri: "/login?status=reset",
      errorUri: "/forgot?status=invalid_sptoken",
      view: "change-password"
    },
    id_site: {
      enabled: false,
      uri: "/idSiteResult",
      loginUri: "",
      forgotUri: "/#/forgot",
      registerUri: "/#/register"
    },
    me: {
      enabled: false,
      uri: "/me"
    }
  }
})