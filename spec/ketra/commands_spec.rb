require 'spec_helper'

describe Ketra::Commands do
  subject do
    Ketra::Commands
  end
  describe "#activate_button" do
    it "defaults Level to 65535" do
      expect(Ketra.client).to receive(:post).with(anything(), hash_including(:Level => 65535 ))
      subject.activate_button('kp', 'btn')
    end
  end

  describe "#push_button" do
    it "includes idempotency_key String as a query_param" do
      expect(Ketra.client).to receive(:post).with(anything(), hash_including(:query_params => { :idempotency_key => kind_of(String) }))
      subject.push_button('kp', 'btn')
    end
  end
end
