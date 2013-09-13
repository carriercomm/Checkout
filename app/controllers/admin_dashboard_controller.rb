class DashboardController < ApplicationController

  def index
    # @outgoing_loans =
    # @incoming_loans =

    # show missing components
    # under list of missing components, be able to filter by a group
    @missing_inventory_records = InventoryRecord
      .currently_missing
      .joins(:component => [:kit])
      .includes(:component => [:kit])
      .decorate

    # show orphaned components
    # TODO: show more than the count
    @orphaned_components = Component
      .includes(:component_models)
      .where("kit_id IS NULL")
      .order(:component_model_id)
      .count()

    # show empty kits
    # TODO: show more than the count
    @empty_kits = Kit
      .select('kits.id, count(components.kit_id) as cnt')
      .joins('LEFT OUTER JOIN components ON kits.id = components.kit_id')
      .group("kits.id")
      .having("count(components.kit_id) = 0")
      .all
      .count
  end

end
