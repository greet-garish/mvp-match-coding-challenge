# frozen_string_literal: true

require 'rails_helper'

describe 'Seller' do
  let(:seller) { FactoryBot.create(:seller) }

  describe 'seller can add products' do
    it do
      seller.products.destroy_all

      FactoryBot.create(:product, seller: seller)

      expect(seller.products.count).to eq(1)
    end
  end
end
