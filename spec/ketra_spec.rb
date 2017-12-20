require 'spec_helper'

describe Ketra do
  it 'has a version number' do
    expect(Ketra::VERSION).not_to be nil
  end

  subject { Ketra }
  it { should have_configurable_field :hub_serial }
  
  it { should have_configurable_field :client_id }
  
  it { should have_configurable_field :client_secret }

  it "should only create a client once" do
    first_client = subject.client
    expect(first_client).to_not be nil
    expect(subject.client).to eq(first_client)
  end
  
end
