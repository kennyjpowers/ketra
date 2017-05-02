require 'oauth2'

require "ketra/version"
require "ketra/ketra_client"

module Ketra
  class Error < RuntimeError; end

  class << self
    attr_writer :callback_url
    #TODO add permission_scopes
  end

  # Make Ketra.client_id and Ketra.client_secret global but also local to threads

  def self.client_id
    Thread.current[:ketra_client_id] || @client_id
  end

  def self.client_id=(id)
    @client_id ||= id
    Thread.current[:ketra_client_id] = id
  end

  def self.client_secret
    Thread.current[:client_secret] || @client_secret    
  end

  def self.client_secret=(secret)
    @client_secret ||= secret
    Thread.current[:ketra_client_secret] = secret
  end

  PRODUCTION_HOST = 'https://my.goketra.com'
  API_VERSION = 'v4'

  # Set the environment, accepts :production (TODO add :sandbox environment).
  # Defaults to :production
  # will raise an exception when set to an unrecognized environment
  def self.environment=(env)
    unless [:production].include?(env)
      raise(ArguementError, "environment must be set to :production")
    end
    @environment = env
    @host = PRODUCTION_HOST
  end

  def self.environment
    @environment || :production
  end

  def self.host
    @host || PRODUCTION_HOST
  end

  # Set the authorization grant type
  # accepts either :implicit or :password
  # Defaults to :implicit
  def self.authorization_grant=(grant_type)
    unless [:code, :password].include?(grant_type)
      raise(ArgumentError, "grant type must be set to either :code or :password")
    end
    @authorization_grant = grant_type
  end
  
  def self.authorization_grant
    @authorization_grant || :code
  end
  
  # Allow throwing API errors
  def self.silent_errors=(bool)
    unless [TrueClass, FalseClass].include?(bool.class)
      raise(ArguementError, "Silent errors must be set to either true or false")
    end
    @silent_errors = bool
  end

  def self.silenet_errors
    @silent_errors.nil? ? false : @silent_errors
  end

  def self.callback_url
    @callback_url || 'urn:ietf:wg:oauth:2.0:oob'
  end

  def self.authorization_url
    client.authorization_url
  end

  # Request Access Token
  # credentials should be key/values based on grant type
  # grant :code should include :authorization_code
  # grant :password should include :username and :password
  def self.authorize(credentials)
    client.authorize(credentials)
  end

  def self.access_token
    client.access_token
  end

  private

  def self.client
    @client ||= KetraClient.new
  end
  

  
  
end
