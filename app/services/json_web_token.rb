require 'jwt'

class JsonWebToken
  class << self
    SECRET_KEY = Rails.application.secrets.secret_key_base

    def encode(payload, exp = 24.hours.from_now)
      JWT.encode({**payload, exp: exp.to_i}, SECRET_KEY)
    end

    def decode(token)
      JWT.decode(token, SECRET_KEY).first
    end
  end
end
