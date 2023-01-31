# frozen_string_literal: true

require 'rails_helper'

describe 'Product' do
  describe '#cost' do
    it 'must be a multiple of 5' do
      expect(FactoryBot.build(:product, cost: 3).valid?).to be(false)

      expect(FactoryBot.build(:product, cost: 5).valid?).to be(true)
    end
  end
end
