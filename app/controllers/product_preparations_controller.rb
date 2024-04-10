# frozen_string_literal: true

require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class ProductPreparationsController < ApplicationController
  before_action :set_product_preparations, only: %i[edit update destroy]
  before_action :load_references, only: %i[new edit]
  # GET /product_preparations
  def index
    @product_preparations = ProductPreparation.includes(preparation_items: :product)
  end

  # GET /product_preparations/1/edit
  def edit; end

  # GET /product_preparations/:id
  def show; end

  # GET /product_preparations/new
  def new
    @product_preparation = ProductPreparation.new
  end

  # POST /product_preparations
  def create
    @product_preparation = ProductPreparation.new(product_preparations_params)

    if @product_preparation.save
      redirect_to product_preparations_path, notice: 'Preparação de Produto criado com sucesso.'
    else
      render :new
    end
  end

  def create_product_preparations
    product_preparation_attributes = [
      {
        description: load_product_preparations.map do |preparation|
                       "AmazonOrderID: #{preparation[:amazon_order_id]}"
                     end.join(', '),
        preparation_items_attributes: load_product_preparations.map do |preparation|
          {
            product_id: preparation[:product_id],
            quantity: preparation[:number_of_items_unshipped],
            kind: 'pending'
          }
        end
      }
    ]

    ActiveRecord::Base.transaction do
      ProductPreparation.create!(product_preparation_attributes)

      permitted_params.each do |param|
        OrderMarkup.find_or_create_by!(amazon_order_id: param[:amazon_order_id])
                   .update(status: permitted_params.first[:order_status])
      end
    end
  end

  # PATCH/PUT /product_preparations/1
  def update
    if @product_preparation.update(product_preparations_params)
      redirect_to product_preparations_path, notice: 'Preparação de Produto atualizado com sucesso.'
    else
      render :edit
    end
  end

  # DELETE /product_preparations/1
  def destroy
    @product_preparation.destroy
    redirect_to product_preparations_path, notice: 'Preparação de Produto excluído com sucesso.'
  end

  def generate_tag
    product_preparation_ids_array = params[:product_preparation_ids].split(',')
    product_preparation_ids_integers = []
    product_preparation_ids_array.map do |id|
      product_preparation_ids_integers << id.to_i
    end

    @preparation_items = PreparationItem.where(id: product_preparation_ids_integers)

    respond_to do |format|
      format.pdf do
        render pdf: 'generate_tag'
      end
    end
  end

  def generate_fnsku_tag
    product_preparation_ids_array = params[:product_preparation_ids].split(',')
    product_preparation_ids_integers = []
    product_preparation_ids_array.map do |id|
      product_preparation_ids_integers << id.to_i
    end

    @preparation_items = PreparationItem.where(id: product_preparation_ids_integers)

    respond_to do |format|
      format.pdf do
        render pdf: 'generate_fnsku_tag', page_height: 30, page_width: 80, outline: { outline: false },
               margin: { top: 1, bottom: 0, left: 1, right: 1 }
      end
    end
  end

  private

  def load_references
    @products = Product.all
  end

  # Set product_preparation by ID
  def set_product_preparations
    @product_preparation = ProductPreparation.find(params[:id])
  end

  def load_product_preparations
    @load_product_preparations ||= permitted_params.map do |order|
      product = OrderItem.find_by(amazon_order_id: order[:amazon_order_id])&.product
      product_id = product&.id

      order.merge({ product_id: })
    end
  end

  def permitted_params
    permit_params = params.permit(selected_orders: %I[amazon_order_id number_of_items_unshipped order_status])
    permit_params[:selected_orders].values.map(&:to_h)
  end

  # It allows only useful parameters.
  def product_preparations_params
    params.require(:product_preparation).permit(
      :description,
      :_destroy,
      preparation_items_attributes: %i[
        id
        product_id
        quantity
        kind
        created_at
        updated_at
        _destroy
      ]
    )
  end
end
