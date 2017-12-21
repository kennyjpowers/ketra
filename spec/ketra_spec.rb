require 'spec_helper'

describe Ketra do
  it 'has a version number' do
    expect(Ketra::VERSION).not_to be nil
  end

  subject { Ketra }

  %w[hub_serial client_id client_secret].each do |field|
    it "has configurable field #{field}" do
      expect(subject).to respond_to(field)
      expect(subject).to respond_to("#{field}=") 
    end
  end

  it "should only create a client once" do
    first_client = subject.client
    expect(first_client).to_not be nil
    expect(subject.client).to eq(first_client)
  end
  
end
