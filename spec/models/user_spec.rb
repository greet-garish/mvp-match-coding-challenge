# frozen_string_literal: true

require 'rails_helper'

describe 'User' do
  let(:user) { FactoryBot.build(:user) }

  describe 'username' do
    it 'must be present and uniq' do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.build(:user, username: user1.username)

      expect(user2.valid?).to be(false)
    end
  end

  describe 'password' do
    it 'must be present' do
      user = FactoryBot.build(:user, password: nil)

      expect(user.valid?).to be(false)
    end
  end

  describe 'roles' do
    context 'when seller' do
      let(:seller) { FactoryBot.build(:user, :seller) }

      it { expect(seller.seller?).to be(true) }
      it { expect(seller.buyer?).to be(false) }
    end

    context 'when buyer' do
      let(:buyer) { FactoryBot.build(:user, :buyer) }

      it { expect(buyer.buyer?).to be(true) }
      it { expect(buyer.seller?).to be(false) }
    end
  end

  describe '#password' do
    it 'is not saved to the database in plain text' do
      expect(user.password_digest).not_to eq(user.password)
    end

    it 'authenticates with the correct password' do
      expect(user.authenticate('1234')).to be(user)
    end

    it 'does not authenticate with the wrong password' do
      expect(user.authenticate('1234ojdwoidh')).to be(false)
    end
  end
end
