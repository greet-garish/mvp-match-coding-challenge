# frozen_string_literal: true

require 'rails_helper'

describe 'ApplicationController' do
  let(:user) {  FactoryBot.create(:user) }

  controller do
    def index
      render json: { body: 'ok' }
    end
  end

  context 'when user has auth token set' do
    let(:token) { JsonWebToken.encode({"current_user_id" => user.id, session_id: 'id' }) }

    before {
      request.headers["Authorization"] = token
      stub_const("ApplicationController::AUTHENTICATED_USERS", {user.id => 'id'})
    }

    it 'succeeds when the token is valid' do
      get :index

      expect(response).to have_http_status(:ok)
    end

    context 'when the user is not found' do
      let(:token) { JsonWebToken.encode({"current_user_id" => 1234 }) }

      it 'returns unauthorized' do
        get :index

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'when user does not have auth token set' do
    it 'returns unauthorized' do
      get :index

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
