require 'oauth2'
require 'rest-client'
#require 'byebug'

require "ketra/version"
require "ketra/ketra_client"
require "ketra/commands"

module Ketra
  class Error < RuntimeError; end

  class << self
    attr_writer :callback_url
    attr_accessor :hub_serial
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
    client.access_token.token if client.access_token
  end

  def self.access_token=(token)
    client.access_token = token
  end

  def self.client
    @client ||= KetraClient.new
  end
  

  
  
end
