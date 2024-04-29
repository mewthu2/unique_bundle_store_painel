class DashboardController < ApplicationController
  before_action :load_references, only: [:index, :generate_spreadsheet]
  before_action :product_ranking_references, only: [:product_ranking, :product_ranking_spreadsheet]

  def index; end

  def generate_spreadsheet
    send_data(GenerateSpreadsheetJob.perform_now(@products),
              disposition: %(attachment; filename=products_unique_#{DateTime.now}.xlsx))
  end

  def view_live_orders
    @orders = SearchOrderStatusJob.perform_now(params[:order_kind], params[:next_token], '')
  end

  def change_order_markup_status
    OrderMarkup.find_or_create_by!(amazon_order_id: params[:amazon_order_id]).update(status: params[:status])
  end

  def search_specific_order
    json_response(SearchOrderStatusJob.perform_now(params[:order_kind], '', params[:amazon_order_id]))
  end

  def search_order_items
    json_response(OrderItem.find_by(amazon_order_id: params[:amazon_order_id]))
  end

  def update_order_markups
    UpdateOrderItemsJob.perform_now
  end

  def product_ranking; end

  def product_ranking_spreadsheet
    send_data(ProductRankingSpreadsheetJob.perform_now(params[:year], params[:kind]),
              disposition: %(attachment; filename=products_ranking_#{DateTime.now}.xlsx))
  end

  private

  def product_ranking_references
    @product_sales = ProductSale.where(kind: params[:interval],
                                       week_refference: params[:week_refference].present? ? params[:week_refference] : nil,
                                       month_refference: params[:month_refference].present? ? params[:month_refference] : Date.today.strftime('%B'),
                                       year_refference: params[:year_refference].present? ? params[:year_refference] : Date.today.year)
                                .joins(:product)
                                .where('products.seller_sku LIKE :valor OR
                                  products.asin1 LIKE :valor OR
                                  products.listing_id LIKE :valor OR
                                  products.id_product LIKE :valor OR
                                  products.item_name LIKE :valor OR
                                  products.item_description LIKE :valor OR
                                  products.id LIKE :valor', valor: "#{params[:search]}%")
                                .order(unit_count: :desc)
  end

  def load_references
    @products = Product.left_joins(:preparation_items)
                       .select('products.*,
                           COALESCE(SUM(CASE WHEN preparation_items.kind = "pending" THEN preparation_items.quantity ELSE 0 END), 0) as quantity_preparation,
                           products.id as id,
                           products.updated_at as updated_at')
                       .group('products.id, products.updated_at')
                       .search(params[:search])
                       .by_fulfillment_channel(params[:fulfillment_channel])
                       .by_status(params[:status])
                       .by_active(params[:active])
  end
end
