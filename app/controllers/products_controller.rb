class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def find_by_seller_sku
    order_item = OrderItem.joins(:product).find_by(amazon_order_id: params[:amazon_order_id])
    if order_item.present?
      json_response({
        id: order_item.id,
        amazon_order_id: order_item.amazon_order_id,
        item_name: order_item.product.item_name,
        product_id: order_item.product_id,
        quantity: order_item.quantity,
        created_at: order_item.created_at,
        updated_at: order_item.updated_at,
        supplier_url: order_item.product.supplier_url,
        seller_sku: order_item.product.seller_sku,
        asin1: order_item.product.asin1
      })
    else
      json_response('Order item do not found')
    end
  end

  # GET /products/1/edit
  def edit; end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to dashboard_index_path, notice: 'Produto criado com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      redirect_to dashboard_index_path, notice: 'Produto atualizado com sucesso.'
    else
      render :edit
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
    redirect_to dashboard_index_path, notice: 'Produto excluído com sucesso.'
  end

  private

  # Set product by ID
  def set_product
    @product = Product.find(params[:id])
  end

  # It allows only useful parameters.
  def product_params
    params.require(:product)
          .permit(:item_name,
                  :item_description,
                  :listing_id,
                  :seller_sku,
                  :price,
                  :quantity,
                  :product_id_type,
                  :asin1,
                  :asin2,
                  :asin3,
                  :id_product,
                  :status,
                  :fulfillment_channel,
                  :total_unit_count,
                  :total_sales_amount,
                  :total_unit_count_7,
                  :total_sales_amount_7,
                  :resolver_stock,
                  :supplier_url,
                  :pending_customer_order_quantity
                  )
  end
end
