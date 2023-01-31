class AuthController < ApplicationController
  skip_before_action :authenticate_token!, only: [:create]

  def create
    if user&.authenticate(params[:password])
      new_session_id = generate_session_id
      register_new_session(new_session_id)

      render json: {
        token: JsonWebToken.encode(current_user_id: user.id, session_id: new_session_id),
        number_of_sessions: number_of_sessions
      }
    else
      render json: { errors: "User & Password dont match" }, status: :unauthorized
    end
  end

  def destroy_all_other
    AUTHENTICATED_USERS[current_user.id] = [session_id]

    render json: { current_sessions: user_sessions}
  end

  def destroy
    AUTHENTICATED_USERS[current_user.id] = AUTHENTICATED_USERS[current_user.id].reject{ |i| i == session_id }

    render json: { current_sessions: user_sessions}
  end

  private

  def register_new_session(new_session_id)
    AUTHENTICATED_USERS[user&.id] = [] unless AUTHENTICATED_USERS[user&.id]

    AUTHENTICATED_USERS[user&.id].push(new_session_id)
  end

  def generate_session_id
    Digest::MD5.hexdigest(user&.id.to_s + Time.now.to_f.to_s)
  end

  def number_of_sessions
    AUTHENTICATED_USERS[user.id].count
  end

  def user
    @user ||= User.find_by(username: params[:username])
  end
end
