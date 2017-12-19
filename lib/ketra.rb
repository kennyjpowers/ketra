require 'oauth2'
require 'rest-client'
#require 'byebug'

require "ketra/version"
require "ketra/ketra_client"
require "ketra/commands"

module Ketra
  class Error < RuntimeError; end

  class << self
    attr_accessor :hub_serial
    attr_accessor :client_id
    attr_accessor :client_secret
    
    attr_writer :callback_url 
    attr_writer :authorization_grant
    attr_writer :environment
    
    #TODO add permission_scopes
  end

  def self.callback_url
    @callback_url || 'urn:ietf:wg:oauth:2.0:oob'
  end
  
  def self.authorization_grant
    @authorization_grant || :password
  end

  def self.environment
    @environment || :production
  end

  PRODUCTION_HOST = 'https://my.goketra.com'
  TEST_HOST = 'https://internal-my.goketra.com'

  def self.host
    case environment
    when :production
      PRODUCTION_HOST
    when :test
      TEST_HOST
    else
      raise RuntimeError, "unsupported environment: #{environment}"
    end
  end

  def self.client
    @client ||= KetraClient.new
  end
end
