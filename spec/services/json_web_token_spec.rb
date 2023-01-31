# frozen_string_literal: true

require 'rails_helper'

describe 'JsonWebToken' do
  let(:headers) { { "head" => 'Head!'} }

  describe '.encode' do
    it 'encodes hashes into string' do
      expect(JsonWebToken.encode(headers)).to be_instance_of(String)
    end
  end

  describe '.decode' do
    it 'has expiration date that raises after expired' do
      token = JsonWebToken.encode(headers)

      travel_to(Time.local(2089))

      expect { JsonWebToken.decode(token) }.to raise_error(JWT::ExpiredSignature)
    end

    it 'decodes when not expired' do
      token = JsonWebToken.encode(headers)

      expect(JsonWebToken.decode(token)["head"]).to eq(headers["head"])
    end
  end
end
