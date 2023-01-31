# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Auth", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:res) { JSON.parse(response.body) }

  before { ApplicationController::AUTHENTICATED_USERS.clear() }

  describe 'create' do
    context 'when user and password match' do
      it 'succeeds and returns token' do
        post "/login", params: {username: user.username, password: '1234' }

        expect(response).to have_http_status(:success)
        expect(res['token']).to be_kind_of(String)
      end

      it 'counts the number of times a user logs in' do
        post "/login", params: {username: user.username, password: '1234' }
        expect(JSON.parse(response.body)['number_of_sessions']).to eq(1)

        post "/login", params: {username: user.username, password: '1234' }
        expect(JSON.parse(response.body)['number_of_sessions']).to eq(2)

        post "/login", params: {username: user.username, password: '1234' }
        expect(JSON.parse(response.body)['number_of_sessions']).to eq(3)
      end
    end

    context "when authentication is not successful" do
      it 'returns unauthorized when username doesnt exist' do
        post "/login", params: {username: 'user does not exist', password: '1234' }

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized when username doesnt exist' do
        post "/login", params: {username: user.username, password: '1234ndoeooni' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'logout' do
    it 'logouts out the current session and only the current session' do
      post "/login", params: {username: user.username, password: '1234' }

      post "/login", params: {username: user.username, password: '1234' }
      second_token = JSON.parse(response.body)['token']

      post "/login", params: {username: user.username, password: '1234' }

      post "/logout", headers: {"Authorization" => second_token }
      expect(response).to have_http_status(:ok)

      expect(JSON.parse(response.body)['current_sessions'].length).to eq(2)
    end
  end

  describe 'logout/all' do
    it 'logouts out all other sessions except the current one' do
      post "/login", params: {username: user.username, password: '1234' }

      post "/login", params: {username: user.username, password: '1234' }

      post "/login", params: {username: user.username, password: '1234' }
      third_token = JSON.parse(response.body)['token']

      post "/logout/all", headers: {"Authorization" => third_token }
      expect(response).to have_http_status(:ok)

      expect(JSON.parse(response.body)['current_sessions'].length).to eq(1)
    end
  end
end
