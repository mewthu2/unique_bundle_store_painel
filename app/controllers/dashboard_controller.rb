class DashboardController < ApplicationController
  before_action :load_references, only: [:index, :generate_spreadsheet]

  def index; end

  def generate_spreadsheet
    send_data(GenerateSpreadsheetJob.perform_now(@products),
              disposition: %(attachment; filename=products_unique_#{DateTime.now}.xlsx))
  end

  def view_live_orders
    @orders = SearchOrderStatusJob.perform_now(params[:order_kind], params[:next_token])
  end

  def change_order_markup_status
    OrderMarkup.find_or_create_by!(amazon_order_id: params[:amazon_order_id]).update(status: params[:status])
  end

  private

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
