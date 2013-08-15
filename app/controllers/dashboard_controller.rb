class DashboardController < ApplicationController

  def index
    @loans = LoansDecorator.decorate(current_user.loans.order('loans.starts_at DESC'))
  end

end
