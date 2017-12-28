module Ketra

  # The Ketra::Client class is used for gaining an Access Token for 
  # authorization and performing GET and POST requests to the Ketra API
  class Client
    PRODUCTION_HOST = 'https://my.goketra.com'
    TEST_HOST = 'https://internal-my.goketra.com'
    LOCAL_ENDPOINT_PREFIX = 'ketra.cgi/api/v1'

    attr_accessor :options
    attr_reader :id, :secret, :access_token

    # Instantiate a new Ketra Client using the
    # Client ID and Client Secret registered to your application.
    #
    # @param [String] id the Client ID value
    # @param [String] secret the Client Secret value
    # @param [Hash] options the options to create the client with
    # @options options [Symbol] :server (:production) which authorization server to use to get an Access Token (:production or :test)
    # @options options [String] :redirect_uri the redirect uri for the authorization code OAuth2 grant type
    # @options options [String] :hub_serial the serial number of the Hub to communicate with

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
    def authorization_url
      auth_client.auth_code.authorize_url(:redirect_uri => options[:redirect_uri])
    end

    # Sets the access token based on the authorization_mode option
    #
    # @param [Hash] credentials
    # @options credentials [String] :token previously gained access token value
    # @options credentials [String] :authorization_code code value from the Ketra OAuth2 provider
    # @options credentials [String] :username Ketra Desiadgn Studio username
    # @options credentials [String] :password Design Studio password
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

    def auth_client
      @auth_client ||= OAuth2::Client.new(Ketra.client_id,
                                          Ketra.client_secret,
                                          :site => host,
                                          :ssl => { :verify => false })
    end

    # Requests
      
    def get(endpoint, params = {})
      JSON.parse access_token.get(url(endpoint), :params => params).body
    end
    
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
