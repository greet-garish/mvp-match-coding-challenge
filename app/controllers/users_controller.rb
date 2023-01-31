class UsersController < ApplicationController
  skip_before_action :authenticate_token!, only: [:create]

  before_action :set_user, only: [:show]

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(**user_params, deposit: 0)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if current_user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    current_user.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:username, :password, :role)
  end
end
