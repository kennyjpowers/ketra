require 'spec_helper'

describe Ketra do
  it 'has a version number' do
    expect(Ketra::VERSION).not_to be nil
  end

  subject { Ketra }
  it { should have_configurable_field :hub_serial }
  
  it { should have_configurable_field :client_id }
  
  it { should have_configurable_field :client_secret }
  
  it { should have_configurable_field :callback_url }
  it { should have_default :callback_url, 'urn:ietf:wg:oauth:2.0:oob' }

  it { should have_configurable_field :authorization_grant }
  it { should have_default :authorization_grant, :password }

  it { should have_configurable_field :environment }
  it { should have_default :environment, :production }

  context "when the environment is set to production" do
    before(:example) do
      subject.environment = :production
    end
    it "should have host" do
      expect(subject.host).to_not be_nil
    end
  end

  context "when the environment is set to test" do
    before(:example) do
      subject.environment = :test      
    end
    it "should have host" do
      expect(subject.host).to_not be_nil
    end
  end

  context "when the environmet is set wrong" do
    before(:example) do
      subject.environment = :wrong
    end
    it "should throw an error when accessing the host" do
      expect { subject.host }.to raise_error RuntimeError
    end
  end

  it "should only create a client once" do
    first_client = subject.client
    expect(first_client).to_not be nil
    expect(subject.client).to eq(first_client)
  end
  
end
