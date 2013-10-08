class AccountController < ApplicationController

  decorates_assigned :loans

  def index
    @loans = current_user.active_loans
  end

end
