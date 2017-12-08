require 'spec_helper'

describe Ketra do
  it 'has a version number' do
    expect(Ketra::VERSION).not_to be nil
  end

  subject { Ketra }
  it { should have_configurable_field(:callback_url) }
  it { should have_default(:callback_url, 'urn:ietf:wg:oauth:2.0:oob') }

  it { should have_configurable_field(:hub_serial) }
  
  it { should have_configurable_field_per_thread(:client_id) }

  it { should have_configurable_field_per_thread(:client_secret) }
  
  it { should have_default(:environment, :production) }
  it { should only_accept_valid_symbols_for(:environment, [:production, :test]) }

  it "should have a host" do
    expect(subject.host).to_not be nil
  end

  it { should have_default(:authorization_grant, :code) }
  it { should only_accept_valid_symbols_for(:authorization_grant, [:code, :password]) }

  it "should only create a client once" do
    first_client = subject.client
    expect(first_client).to_not be nil
    expect(subject.client).to eq(first_client)
  end
  
end
