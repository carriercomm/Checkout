class DashboardController < ApplicationController

  decorates_assigned :incoming_loans
  decorates_assigned :outgoing_loans

  def index
    @incoming_loans = Loan.incoming
    @outgoing_loans = Loan.outgoing

    # show missing components
    # under list of missing components, be able to filter by a group
    # @missing_components = Component.missing

    # show orphaned components
    # TODO: show more than the count
    # @orphaned_components = Component
    #   .includes(:component_models)
    #   .where("kit_id IS NULL")
    #   .order(:component_model_id)
    #   .count()

    # show empty kits
    # TODO: show more than the count
    # @empty_kits = Kit
    #   .select('kits.id, count(components.kit_id) as cnt')
    #   .joins('LEFT OUTER JOIN components ON kits.id = components.kit_id')
    #   .group("kits.id")
    #   .having("count(components.kit_id) = 0")
    #   .all
    #   .count
  end

end
