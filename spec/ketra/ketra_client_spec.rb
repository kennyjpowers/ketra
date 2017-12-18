require 'spec_helper'

describe Ketra::KetraClient do
  subject { Ketra::KetraClient.new }
  it "should accept a string for an access token and return a correct OAuth2 Access Token object" do
    test_token = 'token'
    subject.access_token = test_token
    expect(subject.access_token).to be_instance_of(OAuth2::AccessToken)
    expect(subject.access_token.token).to eql(test_token)
  end

  it { should have_default(:hub_discovery_mode, :cloud) }
  it { should only_accept_valid_symbols_for(:hub_discovery_mode, [:cloud]) }

  it { should have_default(:api_mode, :local) }
  it { should only_accept_valid_symbols_for(:api_mode, [:local]) }

  context "when authorization grant is :code" do
    before(:example) do
      allow(Ketra).to receive(:authorization_grant).and_return(:code)
    end
    it "should return a valid authorization_url" do
      expect(subject.authorization_url).to_not be_nil
      expect(subject.authorization_url).to be_url
    end
    it "should use :authorization_code credential to get a token" do
      auth_client_double = instance_double("OAuth2::Client")
      auth_code_double = instance_double("OAuth2::Strategy::AuthCode")
      allow(auth_code_double).to receive(:get_token).and_return("token")
      allow(auth_client_double).to receive(:auth_code).and_return(auth_code_double)
      allow(OAuth2::Client).to receive(:new).and_return(auth_client_double)
      credentials = {}
      expect { subject.authorize(credentials) }.to raise_error(ArgumentError)
      credentials = { authorization_code: "test code"}
      expect(auth_code_double).to receive(:get_token).with("test code", { redirect_uri: Ketra.callback_url })
      subject.authorize(credentials)
      expect(subject.access_token).to_not be_nil
    end
  end

  context "when Ketra.authorization_grant is :password" do
    before(:example) do
      allow(Ketra).to receive(:authorization_grant).and_return(:password)
    end
    it "should raise error for authotization_url" do
      expect { subject.authorization_url }.to raise_error(NotImplementedError)
    end

    it "should use :username and :password credentials to get a token" do
      auth_client_double = instance_double("OAuth2::Client")
      password_double = instance_double("OAuth2::Strategy::Password")
      allow(password_double).to receive(:get_token).and_return("token")
      allow(auth_client_double).to receive(:password).and_return(password_double)
      allow(OAuth2::Client).to receive(:new).and_return(auth_client_double)
      credentials = {}
      expect { subject.authorize(credentials) }.to raise_error(ArgumentError)
      credentials = { username: "test user", password: "password" }
      expect(password_double).to receive(:get_token).with("test user", "password")
      subject.authorize(credentials)
      expect(subject.access_token).to_not be_nil
    end
  end  
end
