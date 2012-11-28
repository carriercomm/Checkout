class InventoryRecordDecorator < ApplicationDecorator
  decorates :inventory_record
  decorates_association :component
  decorates_association :inventory_status
  decorates_association :loan

  def style
    case inventory_status_id
    when 2
      ".info"    # accessioned
    when 3
      ".success" # inventoried
    when 4
      ".error"   # missing
    else
      ""
    end
  end

  def created_at
    h.l(model.created_at, :format => :tabular)
  end

end
