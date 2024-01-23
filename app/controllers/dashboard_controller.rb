class DashboardController < ApplicationController
  before_action :load_form_references, only: [:index]
  protect_from_forgery except: :modal_test

  def index
    @products = Product.search(params[:search])
                       .see_rules(params[:all])
                       .by_status(params[:status])
                       .paginate(page: params[:page], per_page: params_per_page(params[:per_page]))
  end

  private

  def load_form_references; end
end
