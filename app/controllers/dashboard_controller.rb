class DashboardController < ApplicationController
  before_action :load_references, only: [:generate_spreadsheet]

  def index
    @products = Product.search(params[:search])
                       .see_rules(params[:all])
                       .by_fulfillment_channel(params[:fulfillment_channel])
                       .by_status(params[:status])
                       .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  def generate_spreadsheet
    send_data(GenerateSpreadsheetJob.perform_now(@products),
              disposition: %(attachment; filename=products_unique_#{DateTime.now}.xlsx))
  end

  private

  def load_references
    @products = Product.where(status: 'Active')
  end
end
