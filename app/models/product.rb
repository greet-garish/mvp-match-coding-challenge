class Product < ApplicationRecord
  belongs_to :seller

  validates :cost, multiple_of_five: true
end
