require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:token) { JsonWebToken.encode({"current_user_id" => user.id, session_id: 'id' }) }
  let(:headers) { {"Authorization" => token }}

  let(:user) { FactoryBot.create(:user) }
  let(:res) { JSON.parse(response.body) }

  before {
    stub_const("ApplicationController::AUTHENTICATED_USERS", {user.id => 'id'})
  }

  describe "show" do
    let(:another_user) { FactoryBot.create(:user) }

    it 'gets a user by id' do
      get "/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:ok)

      expect(res['username']).to eq(user.username)
      expect(res.keys).to eq(["id", "username", "password_digest", "deposit", "role", "created_at", "updated_at"])

      get "/users/#{another_user.id}", headers: headers
      expect(response).to have_http_status(:ok)

      expect(JSON.parse(response.body)['username']).to eq(another_user.username)
    end
  end

  describe "create" do
    it 'unauthenticated users can create a new user' do
      post "/users", params: {user: {username: 'machine god', password: '1234', role: 'seller'}}

      expect(response).to have_http_status(:created)

      expect(res.slice('username', 'deposit', 'id', 'role')).to eq({
                                                                     'id' => 2,
                                                                     'username' => "machine god",
                                                                     'deposit' => 0,
                                                                     'role' => "seller",
                                                                   }
                                                                )
    end

    it 'does not allow for the same username to be repeated' do
      post "/users", params: {user: {username: 'machine god', password: '1234', role: 'seller'}}
      post "/users", params: {user: {username: 'machine god', password: '1234', role: 'seller'}}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(res).to eq({"username"=>["has already been taken"]})
    end
  end

  describe "update" do
    it "updates a user" do
      patch "/users/#{user.id}", params: { user: {username: 'new user name', role: 'seller'} }, headers: headers

      expect(response).to have_http_status(:ok)

      reloaded_user = User.find(user.id)

      expect(reloaded_user.username).to eq('new user name')
      expect(reloaded_user.role).to eq('seller')
      expect(reloaded_user.type).to eq('Seller')
    end
  end

  describe "destroy" do
    it "destroys the current user" do
      delete "/users/#{user.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(User.count).to eq(0)
    end

    context "when the user is a seller with products" do
      let(:user) { FactoryBot.create(:seller) }
      let!(:products) { [FactoryBot.create(:product, seller: user), FactoryBot.create(:product, seller: user)] }

      it "destroys the seller and it's products" do
        expect{
          delete "/users/#{user.id}", headers: headers
        }.to change {
          Product.count
        }.from(2).to(0)

        expect(response).to have_http_status(:no_content)
      end
    end
  end


  describe "when the user is not authenticated" do
    let(:product) { FactoryBot.create(:product) }

    it 'can only create a new user' do
      delete "/users/#{user.id}"
      expect(response).to have_http_status(:unauthorized)
      expect(res).to eq({"errors"=>["No auth token set"]})

      patch "/users/#{user.id}"
      expect(response).to have_http_status(:unauthorized)
      expect(res).to eq({"errors"=>["No auth token set"]})

      get "/users/#{user.id}"
      expect(response).to have_http_status(:unauthorized)
      expect(res).to eq({"errors"=>["No auth token set"]})
    end
  end
end
