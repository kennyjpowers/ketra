module Ketra
  module Commands
    def self.activate_button(keypad_name, button_name, level=65535)
      endpoint = "activateButton?keypadName=#{keypad_name}&buttonName=#{button_name}"
      body_params = { "Level": level }
      Ketra.client.post(endpoint, body_params)
    end
  end
end
