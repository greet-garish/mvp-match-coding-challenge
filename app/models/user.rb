class User < ApplicationRecord
  has_secure_password

  enum role: [:buyer, :seller]

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, on: :create

  before_save :set_type_based_on_role

  ROLE_TO_TYPE_MAP = {
    buyer: 'Buyer',
    seller: 'Seller'
  }.with_indifferent_access.freeze

  def set_type_based_on_role
    self.type = ROLE_TO_TYPE_MAP[role]
  end
end
