class DashboardController < ApplicationController

  layout 'sidebar'

  def index
    # @outgoing_loans =
    # @incoming_loans =

    # show missing components
    # under list of missing components, be able to filter by a group
    @missing_components = Component
      .joins(:kit)
      .where("components.missing = ? AND kits.tombstoned = ?", true, false)
      .order(:component_model_id)
      .count()

    # show orphaned components
    @orphaned_components = Component
      .includes(:component_models)
      .where("kit_id IS NULL")
      .order(:component_model_id)
      .count()

    # show empty kits
    @empty_kits = Kit
      .select('kits.id, count(components.kit_id) as cnt')
      .joins('LEFT OUTER JOIN components ON kits.id = components.kit_id')
      .group("kits.id")
      .having("count(components.kit_id) = 0")
      .all
      .count
  end

end
