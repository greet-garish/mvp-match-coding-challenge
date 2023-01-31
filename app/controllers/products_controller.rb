class ProductsController < ApplicationController
  skip_before_action :authenticate_token!, only: [:index, :show]

  before_action :validate_seller!, only: [:update, :destroy, :create]
  before_action :set_product, only: [:update, :destroy]

  # GET /products
  def index
    @products = Product.all

    render json: @products
  end

  # GET /products/1
  def show
    render json: Product.find(params[:id])
  end

  # POST /products
  def create
    @product = Product.new({**product_params, seller_id: current_user.id})

    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_product
    begin
      @product = Product.find_by!(id: params[:id], seller_id: current_user.id)
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ["You're not the owner of this product"]}, status: :forbidden
    end
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(:amount, :name, :cost)
  end

  def validate_seller!
    render(json: {errors: ["Only sellers can add/remove/edit products"]}, status: :forbidden) unless current_user.seller?
  end
end
