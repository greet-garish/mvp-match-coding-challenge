class ApplicationController < ActionController::API
  AUTHENTICATED_USERS = { }

  attr_accessor :current_user

  before_action :authenticate_token!

  def authenticate_token!
    begin
      return render(json: {errors: ['No auth token set']}, status: :unauthorized) if !auth_token
      return render(json: {errors: ['Invalid auth token']}, status: :unauthorized) if auth_token && current_user.nil?
      return render(json: {errors: ['Invalid session']}, status: :unauthorized) unless valid_session?
    rescue JWT::ExpiredSignature
      render(json: {errors: ['Signature expired']}, status: :unauthorized)
    end
  end

  def auth_token
    @auth_token ||= (request.headers["Authorization"] || "").split(" ").last
  end

  def session_id
    payload['session_id']
  end

  def payload
    @payload ||= JsonWebToken.decode(auth_token)
  end

  def current_user
    @current_user ||= User.find_by(id: payload["current_user_id"])
  end

  def valid_session?
    user_sessions.include?(session_id)
  end

  def user_sessions
    return [] unless auth_token

    AUTHENTICATED_USERS[current_user&.id] || []
  end
end
