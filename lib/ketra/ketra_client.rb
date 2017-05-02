module Ketra
  class KetraClient

    attr_accessor :access_token

    # Authorization

    def authorization_url
      unless Ketra.authorization_grant == :code
        raise(NotImplementedError, "authorization url is only for grant type :code")
      end
      client.auth_code.authorize_url(:redirect_uri => Ketra.callback_url)
    end

    def authorize(credentials)
      case Ketra.authorization_grant
      when :code
        @access_token ||= client.auth_code.get_token(credentials[:authorization_code], :redirect_uri => Ketra.callback_url)
      when :password
        @access_token ||= client.password.get_token(credentials[:username], credentials[:password])
      end
    end
    
    private

    def client
      @client ||= OAuth2::Client.new(Ketra.client_id,
                                     Ketra.client_secret,
                                     :site => Ketra.host)
    end
    
  end
end
