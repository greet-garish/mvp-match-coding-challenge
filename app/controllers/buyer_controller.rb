class BuyerController < ApplicationController
  before_action :validate_buyer!

  before_action :validate_deposit!, only: [:deposit]
  before_action :validate_purchase!, only: [:purchase]

  attr_accessor :deposit_value

  def deposit
    current_user.update!(deposit: current_user.deposit + deposit_value)

    render(json: { deposit: current_user.reload.deposit })
  end

  def purchase
    total_spent = product.cost * amount
    change = current_user.deposit - product.cost * amount

    ActiveRecord::Base.transaction do
      product.update!(amount: product.amount - amount)
      current_user.update!(deposit: current_user.deposit - total_spent)
    end

    render json: {
      total_spent: total_spent,
      purchased_product_id: product.id,
      change: calculate_change(change)
    }
  end

  def reset
    current_user.update!(deposit: 0)

    render(json: { deposit: current_user.deposit })
  end

  private

  def validate_purchase!
    render(json: {errors: ["Product not found"]}, status: :bad_request) unless product
    render(json: {errors: ["Product unavailable"]}, status: :bad_request) unless product.amount.positive?


    if (product.cost * amount) > current_user.deposit
      render(json: {errors: ["Not enough money, need #{product.cost * amount} has #{current_user.deposit}"]}, status: :bad_request)
    end
  end

  def product
    @product ||= Product.find(params[:product_id])
  end

  def amount
    (params[:amount] || 1).to_i
  end

  def calculate_change(value)
    res = []

    Coins::SUPPORTED.sort.reverse.each do |coin|
      (value / coin).times do
        res << coin
        value = value - coin

      end
    end

    res
  end

  def validate_deposit!
    @deposit_value ||= params[:deposit].to_i

    unless Coins::SUPPORTED.include? deposit_value
      render(json: {errors: ["Unsupported coin value: #{deposit_value}"]}, status: :bad_request)
    end
  end

  def validate_buyer!
    render(json: {errors: ["#{current_user.username} is not a buyer"]}, status: :forbidden) unless current_user.buyer?
  end
end
