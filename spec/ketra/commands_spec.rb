require 'spec_helper'

describe Ketra::Commands do
  subject do
    Ketra::Commands
  end

  let(:correct_activate_button_endpoint) { "activateButton?keypadName=kp&buttonName=btn" }

  let(:default_activate_button_level) { 65535 }

  let(:test_post_resp_double) { instance_double(OAuth2::Response) }

  describe "#activate_button" do
    it "correctly uses the keypad_name and button_name for the endpoint" do
      allow_any_instance_of(Ketra::Client).to receive(:post).with(correct_activate_button_endpoint, anything()) { test_post_resp_double }
      expect(subject.activate_button('kp', 'btn')).to be(test_post_resp_double)
    end

    it "defaults level to 65535" do
      allow_any_instance_of(Ketra::Client).to receive(:post).with(correct_activate_button_endpoint, hash_including(:Level => default_activate_button_level)) { test_post_resp_double }
      expect(subject.activate_button('kp', 'btn')).to be(test_post_resp_double)
    end

    it "passes the given level as post param" do
      allow_any_instance_of(Ketra::Client).to receive(:post).with(correct_activate_button_endpoint, hash_including(:Level => 5000)) { test_post_resp_double }
      expect(subject.activate_button('kp', 'btn', 5000)).to be(test_post_resp_double)
    end
  end
                                          

end
