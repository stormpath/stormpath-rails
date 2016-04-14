require 'spec_helper'

describe Stormpath::Rails::ContentTypeNegotiator do

  HTTP_ACCEPT_JSON = 'application/json'
  HTTP_ACCEPT_HTML = 'text/html'
  HTTP_UNSUPPORTED_ACCEPT_HEADER = 'audio/basic'
  HTTP_UNSUPPORTED_ACCEPT_HEADER_LIST = 'audio/basic, audio/mp3'
  PRODUCES_JSON_FIRST = [HTTP_ACCEPT_JSON, HTTP_ACCEPT_HTML]
  PRODUCES_HTML_FIRST = [HTTP_ACCEPT_HTML, HTTP_ACCEPT_JSON]

  TRANSITIONS = [
    { produces: PRODUCES_JSON_FIRST, http_accept: nil, result: HTTP_ACCEPT_JSON },
    { produces: PRODUCES_JSON_FIRST, http_accept: '*/*', result: HTTP_ACCEPT_JSON },
    { produces: PRODUCES_JSON_FIRST, http_accept: HTTP_ACCEPT_JSON, result: HTTP_ACCEPT_JSON },
    { produces: PRODUCES_JSON_FIRST, http_accept: 'application/json, application/javascript, text/javascript', result: HTTP_ACCEPT_JSON },
    { produces: PRODUCES_JSON_FIRST, http_accept: HTTP_ACCEPT_HTML, result: HTTP_ACCEPT_HTML },
    { produces: PRODUCES_JSON_FIRST, http_accept: HTTP_UNSUPPORTED_ACCEPT_HEADER, result: nil },
    { produces: PRODUCES_JSON_FIRST, http_accept: HTTP_UNSUPPORTED_ACCEPT_HEADER_LIST, result: nil },

    { produces: PRODUCES_HTML_FIRST, http_accept: nil, result: HTTP_ACCEPT_HTML },
    { produces: PRODUCES_HTML_FIRST, http_accept: '*/*', result: HTTP_ACCEPT_HTML },
    { produces: PRODUCES_HTML_FIRST, http_accept: HTTP_ACCEPT_JSON, result: HTTP_ACCEPT_JSON },
    { produces: PRODUCES_HTML_FIRST, http_accept: 'application/json, application/javascript, text/javascript', result: HTTP_ACCEPT_JSON },
    { produces: PRODUCES_HTML_FIRST, http_accept: HTTP_ACCEPT_HTML, result: HTTP_ACCEPT_HTML },
    { produces: PRODUCES_HTML_FIRST, http_accept: HTTP_UNSUPPORTED_ACCEPT_HEADER, result: nil },
    { produces: PRODUCES_HTML_FIRST, http_accept: HTTP_UNSUPPORTED_ACCEPT_HEADER_LIST, result: nil },

    { produces: [HTTP_ACCEPT_JSON], http_accept: nil, result: HTTP_ACCEPT_JSON },
    { produces: [HTTP_ACCEPT_JSON], http_accept: '*/*', result: HTTP_ACCEPT_JSON },
    { produces: [HTTP_ACCEPT_JSON], http_accept: HTTP_ACCEPT_JSON, result: HTTP_ACCEPT_JSON },
    { produces: [HTTP_ACCEPT_JSON], http_accept: 'application/json, application/javascript, text/javascript', result: HTTP_ACCEPT_JSON },
    { produces: [HTTP_ACCEPT_JSON], http_accept: HTTP_ACCEPT_HTML, result: nil },
    { produces: [HTTP_ACCEPT_JSON], http_accept: HTTP_UNSUPPORTED_ACCEPT_HEADER, result: nil },
    { produces: [HTTP_ACCEPT_JSON], http_accept: HTTP_UNSUPPORTED_ACCEPT_HEADER_LIST, result: nil },

    { produces: [HTTP_ACCEPT_HTML], http_accept: nil, result: HTTP_ACCEPT_HTML },
    { produces: [HTTP_ACCEPT_HTML], http_accept: '*/*', result: HTTP_ACCEPT_HTML },
    { produces: [HTTP_ACCEPT_HTML], http_accept: HTTP_ACCEPT_JSON, result: nil },
    { produces: [HTTP_ACCEPT_HTML], http_accept: 'application/json, application/javascript, text/javascript', result: nil },
    { produces: [HTTP_ACCEPT_HTML], http_accept: HTTP_ACCEPT_HTML, result: HTTP_ACCEPT_HTML },
    { produces: [HTTP_ACCEPT_HTML], http_accept: HTTP_UNSUPPORTED_ACCEPT_HEADER, result: nil },
    { produces: [HTTP_ACCEPT_HTML], http_accept: HTTP_UNSUPPORTED_ACCEPT_HEADER_LIST, result: nil }
  ]

  TRANSITIONS.each do |transition|
    http_accept = transition[:http_accept]
    produces    = transition[:produces]
    result      = transition[:result]

    it "when gets #{http_accept || 'nil'} in the accept header and has #{produces} in produces should transition to #{result}" do
      allow(Stormpath::Rails.config.produces).to receive(:accepts) { produces }
      expect(Stormpath::Rails::ContentTypeNegotiator.new(http_accept).call).to eq(result)
    end
  end

end
