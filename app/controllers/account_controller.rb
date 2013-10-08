class AccountController < ApplicationController

  decorates_assigned :loans

  def index
    @loans = current_user.loans.order('loans.starts_at DESC')
  end

end
