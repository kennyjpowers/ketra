require 'securerandom'

module Ketra
  # This module is used to execute specific Ketra API commands
  module Commands

    # Activates a keypad button at a specific brightness level
    #
    # @param [String] keypad the GUID or Name of the keypad containing the button you want to activate
    # @param [String] button the GUID or Name of the keypad button you want to activate
    # @param [Integer] level (65535) the brightness level from 0 to 65535
    # @return [Hash] deserialized response hash
    def self.activate_button(keypad, button, level=65535)
      Ketra.client.post("Keypads/#{keypad}/Buttons/#{button}/Activate",
                        :Level => level)
    end

    # Deactivates a keypad button
    #
    # @param [String] keypad the GUID or Name of the keypad containing the button you want to deactivate
    # @param [String] button the GUID or Name of the keypad button you want to deactivate
    # @return [Hash] deserialized response hash
    def self.deactivate_button(keypad, button)
      Ketra.client.post("Keypads/#{keypad}/Buttons/#{button}/Deactivate",
                        :Level => 0)
    end

    # Pushes a keypad button which will either activate or deactivate based on its current state
    # and the configuration of the keypad settings
    #
    # @param [String] keypad the GUID or Name of the keypad containing the button you want to deactivate
    # @param [String] button the GUID or Name of the keypad button you want to deactivate
    # @return [Hash] deserailized response hash
    def self.push_button(keypad, button)
      Ketra.client.post("Keypads/#{keypad}/Buttons/#{button}/PushButton",
                        :query_params => { :idempotency_key => SecureRandom.hex })
    end

    # Queries for the available Ketra Keypads
    #
    # @return [Hash] deserialized response hash containing the keypad info, see Ketra API documentation for details
    def self.keypads
      Ketra.client.get("Keypads")
    end

    # Queries for the available Ketra Groups
    #
    # @return [Hash] deserialized response hash containing the group info, see Ketra API documentation for details
    def self.groups
      Ketra.client.get("Groups")
    end
  end
end
