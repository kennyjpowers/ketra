require 'oauth2'
require 'rest-client'
#require 'byebug'

require "./ketra/version"
require "./ketra/client"
require "./ketra/commands"

module Ketra
  class Error < RuntimeError; end

  class << self
    attr_accessor :hub_serial
    attr_accessor :client_id
    attr_accessor :client_secret
    
    #TODO add permission_scopes
  end

  def self.client
    @client ||= Client.new client_id, client_secret, :hub_serial => hub_serial
  end
end
