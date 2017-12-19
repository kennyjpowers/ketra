require 'spec_helper'

describe Ketra::KetraClient do
  subject { Ketra.client }
  it "should accept a string for an access token and create OAuth2 Access Token object" do
    test_token = 'token'
    subject.access_token = test_token
    expect(subject.access_token).to be_instance_of(OAuth2::AccessToken)
    expect(subject.access_token.token).to eql(test_token)
    subject.instance_variable_set("@access_token", nil)
  end

  it { should have_configurable_field :hub_discovery_mode }
  it { should have_default :hub_discovery_mode, :cloud }

  it { should have_configurable_field :api_mode }
  it { should have_default :api_mode, :local }

  it "should have authorization url" do
    expect(subject.authorization_url).to_not be_nil
  end

  context "before setting Ketra hub serial" do
    it "calling get should raise an error" do
      expect { subject.get "testing" }.to raise_error(RuntimeError)
    end

    it "calling post should raise an error" do
      expect { subject.post "testing" }.to raise_error(RuntimeError)
    end
  end

  context "after setting Ketra hub serial" do
    before(:each) do
      Ketra.hub_serial = "KP00000000"
    end
    context "when hub discovery mode is set wrong" do
      before(:each) do
        subject.hub_discovery_mode = :wrong
      end
      # it "calling get should raise an error" do
      #   expect { subject.get "testing" }.to raise_error(RuntimeError)
      # end
      
      # it "calling post should raise an error" do
      #   expect { subject.post "testing" }.to raise_error(RuntimeError)
      # end
    end

    context "when hub discovery mode is :cloud" do
      before(:each) do
        subject.hub_discovery_mode = :cloud
      end
      context "when hub is not discoverable" do
        # it "calling get should raise an error" do
        #   expect { subject.get "testing" }.to raise_error(RuntimeError)
        # end
        
        # it "calling post should raise an error" do
        #   expect { subject.post "testing" }.to raise_error(RuntimeError)
        # end
      end
      context "when hub is discoverable" do
        before(:each) do
          Ketra.environment = :production
          empty_success_response_double = instance_double("OAuth2::Response")
          allow(empty_success_response_double).to receive(:status) { 200 }

          discovery_resp_double = instance_double("OAuth2::Response")
          allow(discovery_resp_double).to receive(:parsed) do
            hash = { "content" =>
                     [
                       { "serial_number" => "KP00000000", "internal_ip" => "1.1.1.1"}
                     ]
                   }
          end
          allow_any_instance_of(OAuth2::Client).to receive(:request) { empty_success_response_double }
          allow_any_instance_of(OAuth2::Client).to receive(:request).with(:get,
                                                          "#{Ketra.host}/api/n4/v1/query") do
            discovery_resp_double
          end
        end
        it "calling get should raise an error" do
          expect { subject.get "testing" }.to raise_error(NoMethodError)
        end
        
        it "calling post should raise an error" do
          expect { subject.post "testing" }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
