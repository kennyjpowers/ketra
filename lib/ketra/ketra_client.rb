require 'byebug'

module Ketra
  class KetraClient
    LOCAL_ENDPOINT_PREFIX = 'ketra.cgi/api/v1'
    attr_reader :access_token

    def access_token=(token)
      @access_token = OAuth2::AccessToken.new(auth_client, token)
    end

    # set the hub discovery mode, accepts: :cloud
    # TODO implement :ssdp
    attr_writer :hub_discovery_mode

    def hub_discovery_mode
      @hub_discovery_mode || :cloud
    end

    # set the api mode, accepts: :local TODO implement :remote
    # :local mode makes calls directly to the hub
    attr_writer :api_mode

    def api_mode
      @api_mode || :local
    end
    
    # Authorization

    def authorization_url
      auth_client.auth_code.authorize_url(:redirect_uri => Ketra.callback_url)
    end

    def authorize(credentials)
      case Ketra.authorization_grant
      when :code
        authorize_with_code credentials[:authorization_code]
      when :password
        authorize_with_password credentials[:username], credentials[:password]
      else
        raise RuntimeError, "unsupported authorization grant: #{Ketra.authorization_grant}"
      end
    end

    def authorize_with_code(authorization_code)
      @access_token = auth_client.auth_code.get_token(authorization_code,
                                                      :redirect_uri => Ketra.callback_url)
    end

    def authorize_with_password(username, password)
      @access_token = auth_client.password.get_token(username, password)
    end
      
    def get(endpoint, params = {})
      @access_token.get url(endpoint),
                        { params: params }
    end
    
    def post(endpoint, body_params={})
      @access_token.get url(endpoint),
                        {
                          body: JSON.generate(body_params),
                          headers: { 'Content-Type' => 'application/json' }
                        }
    end
    
    private

    def url(endpoint)
      case api_mode
      when :local
        "#{local_url}/#{endpoint}"
      else
        raise RunTimeError, "unsupported api mode: #{api_mode}"
      end
    end
    
    def local_url
      "https://#{hub_ip}/#{LOCAL_ENDPOINT_PREFIX}"
    end

    def hub_ip
      @hub_ip || discover_hub(Ketra.hub_serial)
    end

    def discover_hub(serial_number)
      raise RuntimeError, "invalid hub serial: #{serial_number}" if serial_number.nil?
      case hub_discovery_mode
      when :cloud
        cloud_discovery(serial_number)
      else
        raise RuntimeError, "unsupported hub discovery mode: #{hub_discovery_mode}"
      end
    end

    def cloud_discovery(serial_number)
      @hub_ip ||= perform_cloud_hub_discovery(serial_number)
    end
    
    def perform_cloud_hub_discovery(serial_number)
      response = @auth_client.request :get, "#{Ketra.host}/api/n4/v1/query"
      info = response.parsed["content"].detect { |h| h["serial_number"] == serial_number }
      raise RuntimeError, "Could not discover hub with serial: #{serial_number}" if info.nil?
      info["internal_ip"]
    end
    
    def auth_client
      @auth_client ||= OAuth2::Client.new(Ketra.client_id,
                                          Ketra.client_secret,
                                          :site => Ketra.host)
    end
  end
end
