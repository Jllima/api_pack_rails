require "rails_helper"

describe ApplicationController, type: :controller do
  let!(:user) { create(:user) }
  
  let(:headers) { { 'Authorization' => token_generator(user.id) } }
  let(:invalid_headers) { { 'Authorization' => nil } }

  describe "#authorize_request" do
    context "when auth token is passed" do
      before { allow(request).to receive(:headers).and_return(headers) }

      it { expect(subject.instance_eval { authorize_request }).to eq(user) }
    end

    context "when auth token is not passed" do
      before do
        allow(request).to receive(:headers).and_return(invalid_headers)
      end

      it { expect { subject.instance_eval { authorize_request } }.
            to raise_error(ApiPack::Errors::Auth::MissingToken, /Missing token/) }
    end
  end
end