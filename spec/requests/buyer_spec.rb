require 'rails_helper'

RSpec.describe "Buyers", type: :request do
  let(:token) { JsonWebToken.encode({"current_user_id" => user.id, session_id: 'id' }) }
  let(:headers) { {"Authorization" => token }}

  let(:user) { FactoryBot.create(:buyer) }
  let(:product) { FactoryBot.create(:product, cost: 75)}

  let(:res) { JSON.parse(response.body) }

  before {
    stub_const("ApplicationController::AUTHENTICATED_USERS", {user.id => 'id'})
  }

  describe "when user is a buyer" do
    describe "POST /deposit" do
      it "puts money on the user account with a valid deposit" do
        post "/deposit", params: {deposit: 5}, headers: headers

        expect(response).to have_http_status(:success)

        expect(res["deposit"]).to eq(5)
      end

      it "errors with invalid deposit" do
        post "/deposit", params: {deposit: 17}, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(res).to eq({"errors"=>["Unsupported coin value: 17"]})
      end
    end

    describe "POST /purchase/product_id" do
      it "can't buy without money" do
        post "/buy/#{product.id}", headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(res).to eq({"errors"=>["Not enough money, need 75 has 0"]})
      end

      context "when user has credits" do
        let(:initial_deposit) { 200 }

        let(:user) { FactoryBot.create(:buyer, deposit: initial_deposit) }
        let(:product) { FactoryBot.create(:product, cost: 20) }

        it "buys and gives back exchange" do
          post "/buy/#{product.id}", headers: headers

          expect(response).to have_http_status(:success)
          expect(res).to eq({"total_spent"=>20, "purchased_product_id"=>1, "change"=>[50, 50, 50, 20, 10]})

          expect(res['change'].sum).to eq(initial_deposit - product.cost)
        end
      end
    end

    describe "POST /reset" do
      let(:initial_deposit) { 80 }
      let(:user) { FactoryBot.create(:buyer, deposit: initial_deposit) }

      it "resets a user deposit back to zero" do
        expect {
          post "/reset", headers: headers
        }.to change{ user.reload.deposit }.from(initial_deposit).to(0)

        expect(response).to have_http_status(:ok)
        expect(res).to eq({"deposit"=> 0})
      end
    end
  end

  describe "when user is a seller" do
    let(:user) { FactoryBot.create(:seller) }

    it 'gets forbidden on all endpoints' do
      post "/deposit", params: {deposit: 5}, headers: headers
      expect(response).to have_http_status(:forbidden)

      post "/buy/#{product.id}", headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end
end
