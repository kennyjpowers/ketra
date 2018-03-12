require 'spec_helper'

describe Ketra::Client do
  subject do
    Ketra::Client.new('qwe', 'asd')
  end
  
  describe '#initialize' do
    it 'assigns id and secret' do
      expect(subject.id).to eq('qwe')
      expect(subject.secret).to eq('asd')
    end

    it "defaults server option to :production" do
      expect(subject.options[:server]).to be :production
    end
    
    it "allows :production/:test for server option to configure the host site for auth" do
      client = Ketra::Client.new('qwe', 'asd', :server => :production)
      expect(client.options[:server]).to be :production
      production_host = client.auth_client.site
      client = Ketra::Client.new('qwe', 'asd', :server => :test)
      expect(client.options[:server]).to be :test
      test_host = client.auth_client.site
      expect(production_host).to_not be test_host
    end
    
    it "allows changing the server option" do
      client = Ketra::Client.new('qwe', 'asd', :server => :test)
      expect(client.options[:server]).to be :test
      client.options[:server] = :production
      expect(client.options[:server]).to be :production
    end
    
    it "allows :password/:code/:token for authorization_mode option" do
      client = Ketra::Client.new('qwe', 'asd', :authorization_mode => :password)
      expect(client.options[:authorization_mode]).to be :password
      client = Ketra::Client.new('qwe', 'asd', :authorization_mode => :code)
      expect(client.options[:authorization_mode]).to be :code
      client = Ketra::Client.new('qwe', 'asd', :authorization_mode => :token)
      expect(client.options[:authorization_mode]).to be :token
    end
    
    it "allows changing the authorization_mode option" do
      client = Ketra::Client.new('qwe', 'asd', :authorization_grant => :code)
      expect(client.options[:authorization_grant]).to be :code
      client.options[:authorization_grant] = :token
      expect(client.options[:authorization_grant]).to be :token
    end
    
    it "defaults hub_discovery_mode option to :cloud" do
      expect(subject.options[:hub_discovery_mode]).to be :cloud
    end

    it "defaults api_mode option to :local" do
      expect(subject.options[:api_mode]).to be :local
    end

    describe ":redirect_uri option" do
      it "defaults to urn:ietf:wg:oauth:2.0:oob" do
        expect(subject.options[:redirect_uri]).to eq('urn:ietf:wg:oauth:2.0:oob')
      end

      it "can be changed" do
        client = Ketra::Client.new('qwe', 'asd', :redirect_uri => "http://example.com")
        expect(client.options[:redirect_uri]).to eq("http://example.com")
        client.options[:redirect_uri] = "http://new.example.com"
        expect(client.options[:redirect_uri]).to  eq("http://new.example.com")
      end

      it "adds the redirect_uri option to authorization URL" do
        expect(subject.authorization_url).to eq("https://my.goketra.com/oauth/authorize?client_id&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code")
      end
    end
  end
  describe "#authorize" do
    context "when authorization_mode option is :token" do
      it "creates an access token straight from credentials[:token]" do
        client = Ketra::Client.new('qwe', 'asd', :authorization_mode => :token)
        client.authorize(:token => 'token')
        expect(client.instance_variable_get("@access_token").token).to eq('token')
      end
    end
    context "when authorization_mode option is :code" do
      it "uses credentials[:authorization_code] to get an access token" do
        allow_any_instance_of(OAuth2::Strategy::AuthCode).to receive(:get_token).with('code', :redirect_uri => subject.options[:redirect_uri]) { OAuth2::AccessToken.new(subject.auth_client, 'token') }
        client = Ketra::Client.new('qwe', 'asd', :authorization_mode => :code)
        client.authorize(:authorization_code => 'code')
        expect(client.instance_variable_get("@access_token").token).to eq('token')
      end
    end
    context "when authorization_mode option is :password" do
      it "uses credentials[:username] and credentials[:password] to get an access token" do
        allow_any_instance_of(OAuth2::Strategy::Password).to receive(:get_token).with('user', 'password') { OAuth2::AccessToken.new(subject.auth_client, 'token') }
        client = Ketra::Client.new('qwe', 'asd')
        client.authorize(:username => 'user', :password => 'password')
        expect(client.instance_variable_get("@access_token").token).to eq('token')
      end
    end
  end
  describe "#auth_client" do
    it "is only created once" do
      first_client = subject.auth_client
      expect(first_client).to_not be_nil
      expect(first_client).to be subject.auth_client
    end
  end
  
  context "when using :local :api_mode and the hub is discoverable" do
    let(:parsed_discovery_resp) do
        response_hash = { "content" =>
                          [
                            { "serial_number" => "KP00000000", "internal_ip" => "1.1.1.1"}
                          ]
                        }
    end
    let(:discovery_resp_double) { instance_double(OAuth2::Response) }
    let(:query_params) { { 'a' => 1, 'b' => 2 } }
    let(:resp_double) { instance_double(OAuth2::Response) }
    let(:token_double) { instance_double(OAuth2::AccessToken) }
    let(:success_resp) { { "success" => true } }
    let(:json_success) { JSON.generate(success_resp) }
    let(:endpoint) { 'testendpoint' }
    let(:endpoint_match) { /testendpoint$/ }
    let(:correct_headers) { { 'Content-Type' => 'application/json' } }
    let(:post_body_params) { { 'Level' => 65535 } }
    let(:post_params) { post_body_params.merge(:query_params => query_params) }
    before(:each) do
      subject.options[:hub_serial] = 'KP00000000'
      allow(discovery_resp_double).to receive(:parsed) { parsed_discovery_resp }
      
      allow(subject.auth_client).to receive(:request).with(:get, /.*query/) { discovery_resp_double }
    end
    
    describe "#get" do
      before(:each) do
        allow(subject).to receive(:access_token) { token_double }
        allow(resp_double).to receive(:body) { json_success }        
      end
      it "appends the endpoint to the base url" do
        expect(token_double).to receive(:get).with(endpoint_match, anything()) { resp_double }
        subject.get endpoint
      end
      
      it "includes all the params given as query params" do
        expect(token_double).to receive(:get).with(anything(), :params => query_params) { resp_double }
        subject.get 'testendpoint', query_params     
      end

      it "deserializes response body as JSON" do
        expect(token_double).to receive(:get) { resp_double }
        expect( subject.get endpoint, query_params ).to eq success_resp
      end
    end
    
    describe "#post" do
      before(:each) do
        allow(subject).to receive(:access_token) { token_double }
        allow(resp_double).to receive(:body) { json_success }
      end

      it "appends the endpoint to the base url" do
        expect(token_double).to receive(:post).with(endpoint_match, anything()) { resp_double }
        subject.post endpoint
      end

      it "does not mutate the params hash" do
        expect(token_double).to receive(:post) { resp_double }
        params2 = post_params.dup
        subject.post endpoint, post_params
        expect(post_params).to eq params2
      end

      it "uses params[:query_params] as query params" do
        expect(token_double).to receive(:post).with(anything(), hash_including(:params => query_params)) { resp_double }
        subject.post endpoint, post_params
      end
      
      it "#post serializes params besides :query_params into json as the body" do
        expect(token_double).to receive(:post).with(anything(), hash_including(:body => JSON.generate(post_body_params))) { resp_double }
        subject.post endpoint, post_params
      end
      
      it "sets Content-Type header to application/json" do
        expect(token_double).to receive(:post).with(anything(), hash_including(:headers => correct_headers)) { resp_double }
        subject.post endpoint
      end

      it "deserializes response body as JSON" do
        expect(token_double).to receive(:post) { resp_double }
        expect( subject.post endpoint, post_params ).to eq success_resp
      end
    end
  end

  context "when using :remote :api_mode" do
    let(:installation_id) { 'fake-install-guid' }
    let(:hub_serial) { 'fake_serial' }
    let(:token_double) { instance_double(OAuth2::AccessToken) }
    let(:url_match) { /.*#{installation_id}.*#{hub_serial}/ }
    let(:test_url_match) { /internal/ }
    let(:resp_double) { instance_double(OAuth2::Response) }
    let(:success_resp) { { "success" => true } }
    let(:json_success) { JSON.generate(success_resp) }
    before(:each) do
      subject.options[:api_mode] = :remote
      subject.options[:installation_id] = installation_id
      subject.options[:hub_serial] = hub_serial
      allow(subject).to receive(:access_token) { token_double }
      allow(resp_double).to receive(:body) { json_success }
    end
    it "#get uses correct :installation_id and :hub_serial options in url" do
      expect(token_double).to receive(:get).with(url_match, anything()) { resp_double }
      subject.get ''
    end

    it "#post uses correct :installation_id and :hub_serial options in url" do
      expect(token_double).to receive(:post).with(url_match, anything()) { resp_double }
      subject.post '', {}
    end

    it ":test :server option works" do
      subject.options[:server] = :test
      expect(token_double).to receive(:get).with(test_url_match, anything()) { resp_double }
      subject.get ''
    end
  end
end
