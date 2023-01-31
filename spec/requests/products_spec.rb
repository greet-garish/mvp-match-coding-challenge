require 'rails_helper'

RSpec.describe "Products", type: :request do
  let(:token) { JsonWebToken.encode({"current_user_id" => user.id, session_id: 'id'}) }
  let(:headers) { {"Authorization" => token }}

  let(:user) { FactoryBot.create(:seller) }

  let(:res) { JSON.parse(response.body) }

  before {
    stub_const("ApplicationController::AUTHENTICATED_USERS", {user.id => 'id'})
  }

  describe "when the user is a seller" do
    let(:product) { FactoryBot.create(:product, amount: 1, name: 'prod', cost: 5, seller_id: user.id) }

    describe "update" do
      it 'can update products' do
        expect {
          patch "/products/#{product.id}", headers: headers, params: { product: {name: 'new_name'} }
        }.to change {
          product.reload.name
        }.from('prod').to('new_name')

        expect(response).to have_http_status(:ok)
      end
    end

    describe "destroy" do
      before { product }

      it 'can destroy his own products' do
        expect {
          delete "/products/#{product.id}", headers: headers
        }.to change {
          Product.count
        }.from(1).to(0)

        expect(response).to have_http_status(:no_content)
      end
    end

    describe "create" do
      let(:product_params) { {amount: 1, name: 'chocolat', cost: 5} }
      let!(:another_seller) { FactoryBot.create(:seller) }

      it 'can create products' do
        expect {
          post "/products", headers: headers, params: { product: product_params }
        }.to change {
          Product.count
        }.from(0).to(1)

        expect(response).to have_http_status(:created)
      end

      it "can't create products on behalf of other users" do
        post "/products", headers: headers, params: { product: {**product_params, seller_id: another_seller.id} }

        owner = User.find(res["seller_id"])
        expect(owner).to eq(user)
      end
    end
  end

  describe "index" do
    it "allows anyone to see all products" do
      get "/products"
      expect(response).to have_http_status(:ok)
      expect(res).to eq([])
    end
  end

  describe "show" do
    let(:product) { FactoryBot.create(:product, amount: 1, name: 'prod', cost: 5) }

    it "allows anyone to see a product detail" do
      get "/products/#{product.id}"

      expect(response).to have_http_status(:ok)
      expect(res.slice('amount', 'cost', 'name')).to eq({
                                                      "amount" => 1,
                                                      "cost" => 5,
                                                      "name" => "prod",
                                                    })
    end
  end

  describe "when the user not a seller" do
    let(:user) { FactoryBot.create(:buyer) }
    let(:product) { FactoryBot.create(:product) }

    it 'cannot update/destroy/create' do
      post "/products", headers: headers
      expect(response).to have_http_status(:forbidden)
      expect(res).to eq({"errors"=>["Only sellers can add/remove/edit products"]})

      patch "/products/#{product.id}", params: {name: 'New Name'}, headers: headers
      expect(response).to have_http_status(:forbidden)
      expect(res).to eq({"errors"=>["Only sellers can add/remove/edit products"]})

      delete "/products/#{product.id}", headers: headers
      expect(response).to have_http_status(:forbidden)
      expect(res).to eq({"errors"=>["Only sellers can add/remove/edit products"]})
    end
  end

  describe "when user is not the owner of a product" do
    let(:product) { FactoryBot.create(:product) }

    it 'cannot update/destroy' do
      patch "/products/#{product.id}", params: {name: 'New Name'}, headers: headers
      expect(response).to have_http_status(:forbidden)
      expect(res).to eq({"errors"=>["You're not the owner of this product"]})

      delete "/products/#{product.id}", headers: headers
      expect(response).to have_http_status(:forbidden)
      expect(res).to eq({"errors"=>["You're not the owner of this product"]})
    end
  end
end
