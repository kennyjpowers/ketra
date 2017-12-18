module Ketra
  class KetraClient
    LOCAL_ENDPOINT_PREFIX = 'ketra.cgi/api/v1'
    attr_reader :access_token

    def access_token=(token)
      @access_token = OAuth2::AccessToken.new(auth_client, token)
    end

    # set the hub discovery mode, accepts: :cloud TODO implement :ssdp

    def hub_discovery_mode=(mode)
      unless [:cloud].include?(mode)
        raise(ArgumentError, "hub discovery mode must be set to :cloud")
      end
      @hub_discovery_mode = mode
    end

    def hub_discovery_mode
      @hub_discovery_mode || :cloud
    end

    # set the api mode, accepts: :local TODO implement :remote
    # :local mode makes calls directly to the hub
    def api_mode=(mode)
      unless [:local].include?(mode)
        raise(ArgumentError, "api mode must be set to :local")
      end
      @api_mode = mode
    end

    def api_mode
      @api_mode || :local
    end

   

    
    # Authorization

    def authorization_url
      unless Ketra.authorization_grant == :code
        raise(NotImplementedError, "authorization url is only for grant type :code")
      end
      auth_client.auth_code.authorize_url(:redirect_uri => Ketra.callback_url)
    end

    def authorize(credentials)
      case Ketra.authorization_grant
      when :code
        if credentials[:authorization_code].nil?
          raise(ArgumentError, ":code credentials should include :authorization_code")
        end
        self.access_token ||= auth_client.auth_code.get_token(credentials[:authorization_code], :redirect_uri => Ketra.callback_url)
      when :password
        if credentials[:username].nil? or credentials[:password].nil?
          raise(ArgumentError, ":password credentials should include :username and :password")
        end
        self.access_token ||= auth_client.password.get_token(credentials[:username], credentials[:password])
      end
    end

    def get(endpoint, url_params={})
      case api_mode
      when :local
        RestClient::Request.execute(verify_ssl: false,
                                    method: :get,
                                    url: "#{local_url}/#{endpoint}",
                                    user: '',
                                    password: @access_token.token,
                                    content_type: :json,
                                    headers: {params: url_params})
      end
    end

    def post(endpoint, body_params={})
      case api_mode
      when :local
        RestClient::Request.execute(verify_ssl: false,
                                    method: :post,
                                    url: "#{local_url}/#{endpoint}",
                                    user: '',
                                    password: @access_token.token,
                                    content_type: :json,
                                    payload: JSON.generate(body_params))
      end
    end
    
    private

    def hub_ip
      @hub_ip || discover_hub(Ketra.hub_serial)
    end
    
    def local_url
      "https://#{hub_ip}/#{LOCAL_ENDPOINT_PREFIX}"
    end
   

    def discover_hub(serial_number)
      case hub_discovery_mode
      when :cloud
        response = RestClient.get "#{Ketra.host}/api/n4/v1/query"
        object = JSON.parse(response)
        hub_info = object["content"].select{ |h| h["serial_number"] == serial_number }.first
        unless hub_info.nil?
          @hub_ip = hub_info["internal_ip"]
        end
      end
    end
    
    def auth_client
      @auth_client ||= OAuth2::Client.new(Ketra.client_id,
                                          Ketra.client_secret,
                                          :site => Ketra.host)
    end
    
  end
end
