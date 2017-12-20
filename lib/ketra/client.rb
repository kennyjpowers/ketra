require 'byebug'

module Ketra
  class Client
    PRODUCTION_HOST = 'https://my.goketra.com'
    TEST_HOST = 'https://internal-my.goketra.com'
    LOCAL_ENDPOINT_PREFIX = 'ketra.cgi/api/v1'

    attr_accessor :options
    attr_reader :id, :secret

    def initialize(id, secret, options = {}, &block)
      opts = options.dup 
      @id = id
      @secret = secret
      @options = {:server             => :production,
                  :authorization_mode => :password,
                  :redirect_uri       => 'urn:ietf:wg:oauth:2.0:oob',
                  :hub_discovery_mode => :cloud,
                  :connection_build   => block,
                  :api_mode           => :local}.merge(opts)
                  
    end
    
    # Authorization

    def authorization_url
      auth_client.auth_code.authorize_url(:redirect_uri => options[:redirect_uri])
    end

    def authorize(credentials)
      case options[:authorization_mode]
      when :token
        @access_token = OAuth2::AccessToken.new(auth_client, credentials[:token])
      when :code
        @access_token = auth_client.auth_code.get_token(credentials[:authorization_code],
                                                        :redirect_uri => options[:redirect_uri])
      else :password
        @access_token = auth_client.password.get_token(credentials[:username],
                                                       credentials[:password])
      end
    end

    # OAuth Client

    def auth_client
      @auth_client ||= OAuth2::Client.new(Ketra.client_id,
                                          Ketra.client_secret,
                                          { :site => host })
    end

    # Requests
      
    def get(endpoint, params = {})
      @access_token.get url(endpoint),
                        :params => params 
    end
    
    def post(endpoint, params={})
      @access_token.post url(endpoint),
                         :body => JSON.generate(params),
                         :headers => { 'Content-Type' => 'application/json' }

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
      case options[:api_mode]
      when :local
        "#{local_url}/#{endpoint}"
      else
        "#{local_url}/#{endpoint}"
      end
    end
    
    def local_url
      "https://#{hub_ip}/#{LOCAL_ENDPOINT_PREFIX}"
    end

    def hub_ip
      @hub_ip || discover_hub(options[:hub_serial])
    end

    def discover_hub(serial_number)
      case options[:hub_discovery_mode]
      when :cloud
        cloud_discovery(serial_number)
      else
        cloud_discovery(serial_number)
      end
    end

    def cloud_discovery(serial_number)
      @hub_ip ||= perform_cloud_hub_discovery(serial_number)
    end
    
    def perform_cloud_hub_discovery(serial_number)
      response = @auth_client.request :get, "#{host}/api/n4/v1/query"
      info = response.parsed["content"].detect { |h| h["serial_number"] == serial_number }
      raise RuntimeError, "Could not discover hub with serial: #{serial_number}" if info.nil?
      info["internal_ip"]
    end
  end
end
