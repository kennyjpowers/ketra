require 'oauth2'
require 'addressable/uri'

require "ketra/version"
require "ketra/client"
require "ketra/commands"

# Friendly Ruby inteface to the Ketra API
#
# Author::   Kenneth Priester (github: kennyjpowers)
# License::  Available as open source under the terms of the MIT License (http://opensource.org/licenses/MIT)

# This module is used to set the client id, client secret
# and provide access to the actual client.
module Ketra

  class << self
    # Client ID provided by Ketra
    attr_accessor :client_id
    # Client Secret proviced by Ketra
    attr_accessor :client_secret
    
    #TODO add permission_scopes
  end

  # Client used for communicating with the Ketra API.
  # You must call client.Authorize with valid credentials
  # before using any Commands.
  def self.client
    @client ||= Client.new client_id, client_secret
  end
end
