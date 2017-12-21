require 'securerandom'

module Ketra
  module Commands
    def self.activate_button(keypad, button, level=65535)
      Ketra.client.post("Keypads/#{keypad}/Buttons/#{button}/Activate",
                        :Level => level)
    end

    def self.deactivate_button(keypad, button)
      Ketra.client.post("Keypads/#{keypad}/Buttons/#{button}/Deactivate",
                        :Level => 0)
    end

    def self.push_button(keypad, button)
      Ketra.client.post("Keypads/#{keypad}/Buttons/#{button}/PushButton",
                        :query_params => { :idempotency_key => SecureRandom.hex })
    end
    
    def self.keypads
      Ketra.client.get("Keypads")
    end

    def self.groups
      Ketra.client.get("Groups")
    end
  end
end
