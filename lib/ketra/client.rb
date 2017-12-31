module Ketra

  # The Ketra::Client class is used for gaining an Access Token for 
  # authorization and performing GET and POST requests to the Ketra API
  class Client
    # Production Host base url
    PRODUCTION_HOST = 'https://my.goketra.com'
    # Test Host base url
    TEST_HOST = 'https://internal-my.goketra.com'
    # Endpoint prefix to be attached to the base url before the rest of the endpoint
    LOCAL_ENDPOINT_PREFIX = 'ketra.cgi/api/v1'

    attr_accessor :options
    attr_reader :id, :secret, :access_token

    # Instantiate a new Ketra Client using the
    # Client ID and Client Secret registered to your application.
    #
    # @param [String] id the Client ID value
    # @param [String] secret the Client Secret value
    # @param [Hash] options the options to create the client with
    # @option options [Symbol] :server (:production) which authorization server to use to get an Access Token (:production or :test)
    # @option options [String] :redirect_uri the redirect uri for the authorization code OAuth2 grant type
    # @option options [String] :hub_serial the serial number of the Hub to communicate with
    def initialize(id, secret, options = {})
      opts = options.dup 
      @id = id
      @secret = secret
      @options = {:server             => :production,
                  :redirect_uri       => 'urn:ietf:wg:oauth:2.0:oob',
                  :hub_discovery_mode => :cloud,
                  :api_mode           => :local}.merge(opts)
                  
    end
    
    # Authorization

    # The authorize endpoint URL of the Ketra OAuth2 provider
    #
    # @return [String] authorize endpoint URL
    def authorization_url
      auth_client.auth_code.authorize_url(:redirect_uri => options[:redirect_uri])
    end

    # Sets the access token, must supply either the access token, the authorization code,
    # or the Design Studio Username and Password 
    #
    # @param [Hash] credentials
    # @option credentials [String] :token previously gained access token value
    # @option credentials [String] :authorization_code code value from the Ketra OAuth2 provider
    # @option credentials [String] :username Ketra Desiadgn Studio username
    # @option credentials [String] :password Design Studio password
    # @return [OAuth2::AccessToken] Access Token object
    def authorize(credentials)
      if credentials.key?(:token)
        @access_token = OAuth2::AccessToken.new(auth_client, credentials[:token])
      elsif credentials.key?(:authorization_code)
        @access_token = auth_client.auth_code.get_token(credentials[:authorization_code],
                                                        :redirect_uri => options[:redirect_uri])
      elsif credentials.key?(:username)
        @access_token = auth_client.password.get_token(credentials[:username],
                                                       credentials[:password])
      end
    end

    # OAuth Client
    #
    # @return [OAuth2::Client] oauth2 client
    def auth_client
      @auth_client ||= OAuth2::Client.new(Ketra.client_id,
                                          Ketra.client_secret,
                                          :site => host,
                                          :ssl => { :verify => false })
    end

    # performs a GET Request using the OAuth2 Access Token and parses the result as JSON
    #
    # @param [String] endpoint to be appended to the base url
    # @param [Hash] params to be used as query params for the request
    # @return [Hash] deserialized response hash
    def get(endpoint, params = {})
      JSON.parse access_token.get(url(endpoint), :params => params).body
    end

    # performs a POST request using the OAuth2 Access Token and parses the result as JSON
    #
    # @param [String] endpoint to be appended to the base url
    # @param [Hash] params except :query_params will be serialized into JSON and supplied as the body of the request
    # @option params [Hash] :query_params to be used as the query params for the request
    # @return [Hash] deserialized response hash
    def post(endpoint, params = {})
      internal_params = params.dup
      resp = access_token.post url(endpoint),
                               :params => internal_params.delete(:query_params),
                               :body => JSON.generate(internal_params),
                               :headers => { 'Content-Type' => 'application/json' }
      JSON.parse resp.body
    end
    
    private
    
    def host
      case options[:server]
      when :test
        TEST_HOST
      else
        PRODUCTION_HOST
      end
    end
    
    def url(endpoint)
      #TODO implement additional api modes
      url = "#{local_url}/#{endpoint}"
      Addressable::URI.encode(url)
    end
    
    def local_url
      "https://#{hub_ip}/#{LOCAL_ENDPOINT_PREFIX}"
    end
    
    def hub_ip
      @hub_ip || discover_hub(options[:hub_serial])
    end
    
    def discover_hub(serial_number)
      #TODO implement additional hub discovery modes
      cloud_discovery(serial_number)
    end
    
    def cloud_discovery(serial_number)
      @hub_ip ||= perform_cloud_hub_discovery(serial_number)
    end
    
    def perform_cloud_hub_discovery(serial_number)
      response = auth_client.request :get, "#{host}/api/n4/v1/query"
      info = response.parsed["content"].detect { |h| h["serial_number"] == serial_number }
      raise RuntimeError, "Could not discover hub with serial: #{serial_number}" if info.nil?
      info["internal_ip"]
    end
  end
end
